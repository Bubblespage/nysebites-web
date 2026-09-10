import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gcash_portal_modal.dart';
import '../models/product.dart';
// ── FIX: Removed StorageUploader — Firebase Storage requires the Blaze
// billing plan, which isn't enabled on this project. Reverted to base64,
// matching the same fix already applied in order_tracker_modal.dart.

class CheckoutModal extends StatefulWidget {
  final List<Product> cartItems;
  final double totalAmount;
  final String? currentUser;
  final String? currentPhone;
  final String? currentAddress;
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
    this.currentPhone,
    this.currentAddress,
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
  final double _packagingFee = 15.0;
  bool _isSubmitting = false;
  DateTime? _targetDate;
  String? _targetTimeSlot;

  List<String> _getAvailableTimeSlots(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (!isToday) {
      return ['1:00 PM - 3:00 PM', '3:00 PM - 6:00 PM', '6:00 PM - 8:00 PM'];
    }

    final List<String> slots = [];
    if (now.hour < 13) slots.add('1:00 PM - 3:00 PM');
    if (now.hour < 16) slots.add('3:00 PM - 6:00 PM');
    if (now.hour < 18) slots.add('6:00 PM - 8:00 PM');

    if (slots.isEmpty) return ['Next Available Rider'];
    return slots;
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null && widget.currentUser != 'Online Guest') {
      _fullNameController.text = widget.currentUser!;
    }
    if (widget.currentPhone != null && widget.currentPhone!.isNotEmpty) {
      _phoneController.text = widget.currentPhone!;
    }
    if (widget.currentAddress != null && widget.currentAddress!.isNotEmpty) {
      _addressController.text = widget.currentAddress!;
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

    final String deliveryMethod = hasCustomCake ? 'GrabCar' : 'Lalamove';
    final String deliverySpeedLabel = '$deliveryMethod Delivery (Paid to Rider)';

    final String rawPhone = _phoneController.text.trim();
    final String completePhone = rawPhone.startsWith('+63')
        ? rawPhone
        : '+63 $rawPhone';

    // ── FIX: base64-encode reference photos directly instead of uploading
    // to Firebase Storage (unavailable — requires the paid Blaze plan).
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

    // Kept for any older UI path that still reads a single top-level field.
    final String? referenceImageBase64 = customCakes.isNotEmpty
        ? customCakes.first['referenceImageBase64'] as String?
        : null;

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'id': orderId,
      'orderNumber': orderId,
      'userId': FirebaseAuth.instance.currentUser?.uid,
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
      'deliveryFee': 0.0, // Paid to rider
      'packagingFee': _packagingFee,
      'status': status,
      'statusLabel': statusLabel,
      'payment': 'GCash',
      'paymentMethod': 'GCash',
      'deliveryMethod': deliveryMethod,
      'isCustom': hasCustomCake,
      'createdAt': FieldValue.serverTimestamp(),
      'targetDate': _targetDate != null
          ? Timestamp.fromDate(_targetDate!)
          : FieldValue.serverTimestamp(),
      'targetTimeSlot': _targetTimeSlot,
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
        headers: {'Content-Type': 'application/json'},
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

    final bool hasCustomCake = widget.cartItems.any(
      (item) => item.category.toLowerCase() == 'cakes',
    );
    if (hasCustomCake && _targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFD32F2F),
          content: Text(
            'Please select a scheduled delivery date for your custom cake.',
          ),
        ),
      );
      return;
    }
    if (_targetDate != null && _targetTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFD32F2F),
          content: Text('Please select a delivery time slot.'),
        ),
      );
      return;
    }

    if (calculatedGrandTotal > 0) {
      final success = await GCashPortalModal.show(
        context: context,
        amount: calculatedGrandTotal,
        qrAssetPath: gcashQrPath,
        onSubmit: (ref, screenshotBytes) async {
          // ── FIX: base64-encode directly instead of uploading to
          // Firebase Storage (unavailable — requires billing).
          final String? proofBase64 = screenshotBytes != null
              ? base64Encode(screenshotBytes)
              : null;
          await _submitOrderToFirestore(
            calculatedGrandTotal: calculatedGrandTotal,
            referenceNumber: ref,
            paymentProofBase64: proofBase64,
            shouldPop:
                false, // GCash modal handles its own success state and pop
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
    final bool isWebDesktop = screenWidth >= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 24,
        vertical: 12,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWebDesktop ? 980 : 580,
          maxHeight: screenHeight * 0.97,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF7F2), Color(0xFFFFFFFF)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFEAD9), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(60, 34, 22, 0.15),
                blurRadius: 35,
                offset: Offset(0, 15),
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

              double regularItemsTotal = 0.0;
              for (final item in widget.cartItems) {
                if (item.category.toLowerCase() != 'cakes') {
                  regularItemsTotal += item.price;
                }
              }

              final double grandTotal = regularItemsTotal > 0
                  ? regularItemsTotal + _packagingFee
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

                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      physics: isWebDesktop
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      padding: EdgeInsets.fromLTRB(
                        isSmallScreen ? 16 : 22,
                        isSmallScreen ? 12 : 24,
                        isSmallScreen ? 16 : 22,
                        isSmallScreen ? 24 : 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Builder(
                          builder: (context) {
                            final leftCol = <Widget>[
                              _sectionLabel('SCHEDULE DELIVERY'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: InkWell(
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final firstDate = hasCustomCake
                                            ? now.add(const Duration(days: 14))
                                            : now;
                                        final initialDate =
                                            _targetDate != null &&
                                                _targetDate!.isAfter(firstDate)
                                            ? _targetDate!
                                            : firstDate;
                                        final picked = await showDialog<DateTime>(
                                          context: context,
                                          builder: (context) {
                                            DateTime tempDate = initialDate;
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              backgroundColor: Colors.white,
                                              child: Container(
                                                width: 340,
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Select Delivery Date',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF2E1B10,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Theme(
                                                      data: Theme.of(context).copyWith(
                                                        colorScheme:
                                                            const ColorScheme.light(
                                                              primary: Color(
                                                                0xFF8E4A23,
                                                              ),
                                                              onPrimary:
                                                                  Colors.white,
                                                              onSurface: Color(
                                                                0xFF2E1B10,
                                                              ),
                                                            ),
                                                      ),
                                                      child: SizedBox(
                                                        width: 300,
                                                        child:
                                                            CalendarDatePicker(
                                                              initialDate:
                                                                  initialDate,
                                                              firstDate:
                                                                  firstDate,
                                                              lastDate: now.add(
                                                                const Duration(
                                                                  days: 90,
                                                                ),
                                                              ),
                                                              onDateChanged:
                                                                  (date) =>
                                                                      tempDate =
                                                                          date,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xFF756256,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF8E4A23,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                tempDate,
                                                              ),
                                                          child: const Text(
                                                            'Confirm',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _targetDate = picked;
                                            final validSlots =
                                                _getAvailableTimeSlots(picked);
                                            if (_targetTimeSlot == null ||
                                                !validSlots.contains(
                                                  _targetTimeSlot,
                                                )) {
                                              _targetTimeSlot =
                                                  validSlots.first;
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFEFE4D6),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF8E4A23,
                                              ).withValues(alpha: 0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.calendar_month_rounded,
                                              size: 18,
                                              color: Color(0xFF8E4A23),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                _targetDate == null
                                                    ? (hasCustomCake
                                                          ? 'Pick Date (Required)'
                                                          : 'Same-Day Delivery')
                                                    : '${_targetDate!.month}/${_targetDate!.day}/${_targetDate!.year}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      _targetDate == null &&
                                                          hasCustomCake
                                                      ? const Color(0xFFD32F2F)
                                                      : const Color(0xFF8E4A23),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_targetDate != null && 
                                      !(_targetDate!.year == DateTime.now().year && 
                                        _targetDate!.month == DateTime.now().month && 
                                        _targetDate!.day == DateTime.now().day)) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFEFE4D6),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF8E4A23,
                                              ).withValues(alpha: 0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _targetTimeSlot,
                                            isExpanded: true,
                                            isDense: true,
                                            icon: const Icon(
                                              Icons.access_time,
                                              color: Color(0xFF8E4A23),
                                              size: 18,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8E4A23),
                                            ),
                                            dropdownColor: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            items:
                                                _getAvailableTimeSlots(
                                                  _targetDate!,
                                                ).map((slot) {
                                                  String label = slot;
                                                  if (slot.startsWith('1:00'))
                                                    label = '1:00 PM - 3:00 PM';
                                                  else if (slot.startsWith(
                                                    '3:00',
                                                  ))
                                                    label = '3:00 PM - 6:00 PM';
                                                  else if (slot.startsWith(
                                                    '6:00',
                                                  ))
                                                    label = '6:00 PM - 8:00 PM';
                                                  else
                                                    label = slot;
                                                  return DropdownMenuItem(
                                                    value: slot,
                                                    child: Text(label),
                                                  );
                                                }).toList(),
                                            onChanged: (val) {
                                              if (val != null)
                                                setState(
                                                  () => _targetTimeSlot = val,
                                                );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!hasCustomCake) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => setState(() {
                                          _targetDate = null;
                                          _targetTimeSlot = null;
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFFFD6D6),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFFD32F2F,
                                                ).withValues(alpha: 0.06),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Color(0xFFD32F2F),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                              if (hasCustomCake)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8, left: 4),
                                  child: Text(
                                    '* Custom cakes require a minimum 2-week lead time.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF756256),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 28),
                              _sectionLabel('CONTACT & DELIVERY DETAILS'),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fullNameController,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E1B10),
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Recipient Name *',
                                        hintText: 'e.g. Maria Santos',
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.only(
                                            left: 14,
                                            right: 10,
                                          ),
                                          child: Icon(
                                            Icons.person_outline,
                                            size: 18,
                                            color: Color(0xFF8E4A23),
                                          ),
                                        ),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFEFE4D6),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFEFE4D6),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF8E4A23),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 11,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E1B10),
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        labelText: 'Mobile Number *',
                                        hintText: '0917 123 4567',
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4,
                                            top: 4,
                                            bottom: 4,
                                            right: 12,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFDF8F5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFE8D0C3),
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.phone_outlined,
                                                  size: 14,
                                                  color: Color(0xFF8E4A23),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '+63',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 12,
                                                    color: Color(0xFF2E1B10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFEFE4D6),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFEFE4D6),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF8E4A23),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        final cleaned = v.replaceAll(
                                          RegExp(r'\D'),
                                          '',
                                        );
                                        if (cleaned.length < 10) {
                                          return 'Invalid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _addressController,
                                minLines: 1,
                                maxLines: 3,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E1B10),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Complete Delivery Address *',
                                  hintText:
                                      'Unit/House No., Street, Barangay, Subdivision, City',
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 14,
                                      right: 10,
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: Color(0xFF8E4A23),
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  errorStyle: const TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFEFE4D6),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFEFE4D6),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8E4A23),
                                      width: 1.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE57373),
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD32F2F),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Please enter your full delivery address'
                                    : null,
                              ),
                              const SizedBox(height: 28),
                              _sectionLabel('RIDER / BAKE NOTES (Optional)'),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _noteController,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF2E1B10),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'e.g. call upon arrival...',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E8E84),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFDF8F5),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE8D0C3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE8D0C3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8E4A23),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF2E9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFEAD9),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.cookie_outlined,
                                      color: Color(0xFF8E4A23),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Freshly Baked Promise',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF2E1B10),
                                              fontSize: 12.5,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Your sweet treats are prepared with love and the finest ingredients.',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: Color(0xFF756256),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]; // End leftCol

                            final rightCol = <Widget>[
                              if (grandTotal > 0) ...[
                                _sectionLabel('PAYMENT METHOD'),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF8F5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE8D0C3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8E4A23,
                                        ).withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        size: 20,
                                        color: Color(0xFF8E4A23),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'GCash (Online Payment Only)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
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
                                      Icon(
                                        Icons.info_outline,
                                        color: Color(0xFF8E4A23),
                                        size: 20,
                                      ),
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
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFEFE4D6),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8E4A23,
                                        ).withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              _sectionLabel('PAYMENT BREAKDOWN'),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F0),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFFD6D6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFD32F2F,
                                      ).withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Color(0xFFD32F2F),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Delivery Fee Not Included',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 11.5,
                                              color: Color(0xFFD32F2F),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'You must pay the ${hasCustomCake ? 'GrabCar' : 'Lalamove'} driver directly in cash for the delivery fee upon arrival.',
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              color: Color(0xFFD32F2F),
                                              height: 1.4,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9F5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFE4D6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF8E4A23,
                                      ).withValues(alpha: 0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _receiptRow(
                                      'Items Subtotal (${widget.cartItems.length} items)',
                                      '₱${widget.totalAmount.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 8),
                                    _receiptRowWidget(
                                      '${hasCustomCake ? 'GrabCar' : 'Lalamove'} Delivery Fee',
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE4D6),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'Paid to Rider',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFD86A35),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _receiptRow(
                                      'Bakery Eco Seal Packaging',
                                      '₱${_packagingFee.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(
                                      color: Color(0xFFFFE4D6),
                                      thickness: 1.5,
                                      height: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Grand Total:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12.5,
                                            color: Color(0xFF2E1B10),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8E4A23),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '₱${grandTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]; // End rightCol
                            if (isWebDesktop) {
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: leftCol,
                                      ),
                                    ),
                                    const VerticalDivider(
                                      width: 48,
                                      thickness: 1.0,
                                      color: Color(0xFFF5EBE1),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: rightCol,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...leftCol,
                                const SizedBox(height: 24),
                                ...rightCol,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF8E4A23,
                          ).withValues(alpha: 0.04),
                          blurRadius: 32,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isWebDesktop)
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF756256),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Back to Menu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  grandTotal > 0
                                      ? 'Paying via GCash'
                                      : 'Custom Cake Inquiry',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: Color(0xFF756256),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (grandTotal > 0)
                                  Text(
                                    '₱${grandTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF8E4A23),
                                    ),
                                  )
                                else
                                  const Text(
                                    'Payment via Tracker',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF8E4A23),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD97241),
                                    Color(0xFF8E4A23),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF8E4A23,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: (_isSubmitting || !isStoreOpen)
                                    ? null
                                    : () {
                                        _handlePlaceOrder(
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
                            ),
                          ],
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
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFF8E4A23)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Color(0xFF8E4A23),
            ),
          ),
        ],
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

  Widget _receiptRowWidget(String label, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF756256)),
        ),
        valueWidget,
      ],
    );
  }
}