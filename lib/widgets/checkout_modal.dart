import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gcash_portal_modal.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';

class CheckoutModal extends StatefulWidget {
  final List<Product> cartItems;
  final double totalAmount;
  final String? currentUser;
  final Function(
    String orderId,
    int itemCount,
    double grandTotal,
    String paymentMethod,
  )
  onOrderSuccess;

  const CheckoutModal({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    this.currentUser,
    required this.onOrderSuccess,
  });

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _refNumberController = TextEditingController();

  final String _selectedPaymentMethod = 'GCash';
  bool _isGrabCarStandard = true;
  final double _packagingFee = 15.0;
  bool _isSubmitting = false;
  String? _paymentProofBase64;

  Future<void> _pickPaymentProof() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() => _paymentProofBase64 = base64Image);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null && widget.currentUser != 'Online Guest') {
      _fullNameController.text = widget.currentUser!;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _refNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitOrderToFirestore({
    required double activeDeliveryFee,
    required double calculatedGrandTotal,
    String? referenceNumber,
    String? paymentProofBase64,
    bool shouldPop = true,
  }) async {
    final String orderId =
        'NB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final Map<String, int> itemQuantities = {};
    for (final item in widget.cartItems) {
      itemQuantities[item.name] = (itemQuantities[item.name] ?? 0) + 1;
    }

    final String itemizedSummary = itemQuantities.entries
        .map((e) => '${e.value}x ${e.key}')
        .join(', ');

    String status = 'pending_ewallet';
    String statusLabel = '⏳ Verify GCash';

    final bool hasCustomCake = widget.cartItems.any(
      (item) => item.category.toLowerCase() == 'cakes',
    );
    if (hasCustomCake) {
      status = 'pending_spec_review';
      statusLabel = '🎂 Needs Spec Review';
    }

    final String deliverySpeedLabel = _isGrabCarStandard
        ? 'GrabCar Standard Delivery (25-35 mins)'
        : 'GrabCar Priority Express';

    final String rawPhone = _phoneController.text.trim();
    final String completePhone = rawPhone.startsWith('+63')
        ? rawPhone
        : '+63 $rawPhone';

    String? referenceImageBase64;
    for (final item in widget.cartItems) {
      if (item.customImageBytes != null) {
        referenceImageBase64 = base64Encode(item.customImageBytes!);
        break; // Still keep for backwards compatibility
      }
    }

    final Map<String, Map<String, dynamic>> customCakesMap = {};
    for (final item in widget.cartItems) {
      if (item.category.toLowerCase() == 'cakes') {
        final key = '${item.name}_${item.description}';
        if (customCakesMap.containsKey(key)) {
          customCakesMap[key]!['quantity'] =
              (customCakesMap[key]!['quantity'] as int) + 1;
        } else {
          customCakesMap[key] = {
            'name': item.name,
            'description': item.description,
            'referenceImageBase64': item.customImageBytes != null
                ? base64Encode(item.customImageBytes!)
                : null,
            'price': item.price,
            'quantity': 1,
          };
        }
      }
    }
    final List<Map<String, dynamic>> customCakes = customCakesMap.values
        .toList();

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'id': orderId,
      'orderNumber': orderId,
      'customer': _fullNameController.text.trim().isEmpty
          ? (widget.currentUser ?? 'Online Guest')
          : _fullNameController.text.trim(),
      'contact': completePhone,
      'address': _addressController.text.trim(),
      'item': itemizedSummary,
      'specs': deliverySpeedLabel,
      'referenceNumber': referenceNumber,
      'note': _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      'total': '₱${calculatedGrandTotal.toStringAsFixed(2)}',
      'subtotal': widget.totalAmount,
      'baseCakePrice': hasCustomCake ? widget.totalAmount : null,
      'deliveryFee': activeDeliveryFee,
      'packagingFee': _packagingFee,
      'status': status,
      'statusLabel': statusLabel,
      'payment': 'GCash',
      'paymentMethod': 'GCash',
      'deliveryMethod': 'GrabCar',
      'isCustom': hasCustomCake,
      'createdAt': FieldValue.serverTimestamp(),
      'referenceImageBase64': referenceImageBase64,
      'customCakes': customCakes,
      'paymentProofBase64': paymentProofBase64,
    });

    // Trigger Admin Email Notification via EmailJS
    try {
      final customerName = _fullNameController.text.trim().isEmpty
          ? (widget.currentUser ?? 'Online Guest')
          : _fullNameController.text.trim();
          
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': 'service_lknatb4',
          'template_id': 'template_slz600e',
          'user_id': 'v7VSBAFbXx0Qqp1l8',
          'template_params': {
            'order_id': orderId,
            'customer_name': customerName,
            'total': '₱${calculatedGrandTotal.toStringAsFixed(2)}',
            'items': itemizedSummary,
          },
        }),
      );
      
      debugPrint('EmailJS Response: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('Failed to queue email notification: $e');
    }

    if (!mounted) return;
    widget.onOrderSuccess(
      orderId,
      widget.cartItems.length,
      calculatedGrandTotal,
      'GCash',
    );
    if (shouldPop) {
      Navigator.pop(context); // Close the checkout modal
    }
  }

  Future<void> _handlePlaceOrder({
    required double activeDeliveryFee,
    required double calculatedGrandTotal,
    required bool isStoreOpen,
    required String gcashQrPath,
  }) async {
    if (!isStoreOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFD32F2F),
          content: Text('The bakery is currently closed for new orders.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (calculatedGrandTotal > 0) {
      final success = await GCashPortalModal.show(
        context: context,
        amount: calculatedGrandTotal,
        qrAssetPath: gcashQrPath,
        onSubmit: (ref, screenshot) async {
          await _submitOrderToFirestore(
            activeDeliveryFee: activeDeliveryFee,
            calculatedGrandTotal: calculatedGrandTotal,
            referenceNumber: ref,
            paymentProofBase64: screenshot,
            shouldPop: false, // GCash modal handles its own success state and pop
          );
        },
      );
      
      if (success == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      setState(() => _isSubmitting = true);
      try {
        await _submitOrderToFirestore(
          activeDeliveryFee: activeDeliveryFee,
          calculatedGrandTotal: calculatedGrandTotal,
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFD32F2F),
              content: Text('Failed to submit order: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final bool isSmallScreen = screenWidth < 480;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 24,
        vertical: isSmallScreen ? 16 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: screenHeight * 0.90,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEFE4D6)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(60, 34, 22, 0.22),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('settings')
                .doc('storefront')
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() ?? {};

              final bool isStoreOpen = data['isStoreOpen'] ?? true;
              String gcashQr =
                  data['gcashQrUrl'] ?? 'assets/images/qr_code.jpg';
              if (gcashQr == 'assets/images/gcash_qr.png') {
                gcashQr = 'assets/images/qr_code.jpg';
              }

              final double standardDeliveryFee =
                  (data['standardDeliveryFee'] ?? data['deliveryFee'] ?? 80.0)
                      .toDouble();
              final double scheduledDeliveryFee =
                  (data['scheduledDeliveryFee'] ?? 70.0).toDouble();

              final double effectiveDeliveryFee = _isGrabCarStandard
                  ? standardDeliveryFee
                  : scheduledDeliveryFee;

              double regularItemsTotal = 0.0;
              for (final item in widget.cartItems) {
                if (item.category.toLowerCase() != 'cakes') {
                  regularItemsTotal += item.price;
                }
              }

              final double grandTotal = regularItemsTotal > 0
                  ? regularItemsTotal + effectiveDeliveryFee + _packagingFee
                  : 0.0;

              final bool hasCustomCake = widget.cartItems.any(
                (item) => item.category.toLowerCase() == 'cakes',
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF2E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.local_taxi_outlined,
                                color: Color(0xFF8E4A23),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Review & Checkout',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E1B10),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF756256),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFEFE4D6), height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('CONTACT & DELIVERY DETAILS'),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _fullNameController,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E1B10),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Recipient Full Name *',
                                hintText: 'e.g. Maria Santos',
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: Color(0xFF8E4A23),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEFE4D6),
                                  ),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter recipient name'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E1B10),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Mobile Number *',
                                hintText: '917 123 4567',
                                prefixIcon: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  width: 78,
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: 16,
                                        color: Color(0xFF8E4A23),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '+63',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: Color(0xFF2E1B10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEFE4D6),
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Please enter your mobile number';
                                final cleaned = v.replaceAll(RegExp(r'\D'), '');
                                if (cleaned.length < 10)
                                  return 'Please enter a valid 10 or 11-digit mobile number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _addressController,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E1B10),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Complete Delivery Address *',
                                hintText:
                                    'Unit/House No., Street, Barangay, Subdivision, City',
                                prefixIcon: const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Color(0xFF8E4A23),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEFE4D6),
                                  ),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter your full delivery address'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            _sectionLabel('GRABCAR DELIVERY SPEED'),
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                _deliveryOptionCard(
                                  icon: Icons.local_taxi,
                                  title: 'GrabCar Standard Delivery',
                                  subtitle: 'Direct dispatch (25-35 mins)',
                                  priceText:
                                      '₱${standardDeliveryFee.toStringAsFixed(2)}',
                                  isSelected: _isGrabCarStandard,
                                  onTap: () =>
                                      setState(() => _isGrabCarStandard = true),
                                ),
                                const SizedBox(height: 8),
                                _deliveryOptionCard(
                                  icon: Icons.bolt,
                                  title: 'GrabCar Priority Express',
                                  subtitle:
                                      'Dedicated rider straight to doorstep',
                                  priceText:
                                      '₱${scheduledDeliveryFee.toStringAsFixed(2)}',
                                  isSelected: !_isGrabCarStandard,
                                  onTap: () => setState(
                                    () => _isGrabCarStandard = false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            if (grandTotal > 0) ...[
                              _sectionLabel('PAYMENT METHOD'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF8E4A23),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 18,
                                      color: Color(0xFF8E4A23),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'GCash (Online Payment Only)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF2E1B10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF2E9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE8D0C3),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Color(0xFF8E4A23), size: 20),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'You will be redirected to the secure GCash payment portal after clicking Place Sweet Order.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF756256),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (hasCustomCake) ...[
                              const SizedBox(height: 20),
                              _sectionLabel('CUSTOM CAKE PAYMENT'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF8F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE8D0C3),
                                  ),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: Color(0xFF8E4A23),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Payment for custom cakes is not required at checkout. It will be securely handled via GCash inside your Order Tracker once our bakers review and approve your cake design.',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF756256),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Rider / Bake Notes
                            _sectionLabel('RIDER / BAKE NOTES'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _noteController,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF2E1B10),
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. Leave with GrabCar driver, call upon arrival...',
                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E8E84),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEFE4D6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Payment Breakdown
                            _sectionLabel('PAYMENT BREAKDOWN'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFEFE4D6),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _receiptRow(
                                    'Items Subtotal (${widget.cartItems.length} items)',
                                    '₱${widget.totalAmount.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(height: 6),
                                  _receiptRow(
                                    'GrabCar Delivery Fee',
                                    '₱${effectiveDeliveryFee.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(height: 6),
                                  _receiptRow(
                                    'Bakery Eco Seal Packaging',
                                    '₱${_packagingFee.toStringAsFixed(2)}',
                                  ),
                                  const Divider(
                                    color: Color(0xFFEFE4D6),
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Grand Total:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                          color: Color(0xFF2E1B10),
                                        ),
                                      ),
                                      Text(
                                        '₱${grandTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 17,
                                          color: Color(0xFF8E4A23),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFEFE4D6))),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(23),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              grandTotal > 0
                                  ? 'Paying via GCash'
                                  : 'Custom Cake Inquiry',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF756256),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (grandTotal > 0)
                              Text(
                                '₱${grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF8E4A23),
                                ),
                              )
                            else
                              const Text(
                                'Payment via Tracker',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF8E4A23),
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E4A23),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: (_isSubmitting || !isStoreOpen)
                              ? null
                              : () {
                                  _handlePlaceOrder(
                                    activeDeliveryFee: effectiveDeliveryFee,
                                    calculatedGrandTotal: grandTotal,
                                    isStoreOpen: isStoreOpen,
                                    gcashQrPath: gcashQr,
                                  );
                                },
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                ),
                          label: Text(
                            _isSubmitting
                                ? 'Submitting...'
                                : (grandTotal > 0
                                      ? 'Place Sweet Order'
                                      : 'Submit Inquiry'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQrImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('http')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _qrFallback(),
      );
    } else {
      return Image.asset(
        pathOrUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _qrFallback(),
      );
    }
  }

  Widget _qrFallback() {
    return Container(
      color: const Color(0xFFFAF2E9),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 40, color: Color(0xFF8E4A23)),
          SizedBox(height: 4),
          Text(
            'Official QR Ready\nat Counter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF756256),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Color(0xFF8E4A23),
      ),
    );
  }

  Widget _deliveryOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String priceText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF2E9) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8E4A23)
                : const Color(0xFFEFE4D6),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8E4A23)
                    : const Color(0xFFF3E7DC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF8E4A23),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E1B10),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF756256),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              priceText,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF8E4A23),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF756256)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E1B10),
          ),
        ),
      ],
    );
  }
}
