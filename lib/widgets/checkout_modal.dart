import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String _selectedPaymentMethod = 'GCash';
  bool _isStandardDelivery = true;
  final double _packagingFee = 15.0;
  bool _isSubmitting = false;

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

  Future<void> _handlePlaceOrder({
    required double activeDeliveryFee,
    required double calculatedGrandTotal,
    required bool isStoreOpen,
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

    setState(() => _isSubmitting = true);

    final String orderId =
        'NB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final Map<String, int> itemQuantities = {};
    for (final item in widget.cartItems) {
      itemQuantities[item.name] = (itemQuantities[item.name] ?? 0) + 1;
    }

    final String itemizedSummary = itemQuantities.entries
        .map((e) => '${e.value}x ${e.key}')
        .join(', ');

    String status = 'pending_cod';
    String statusLabel = '📋 Confirm COD';

    if (_selectedPaymentMethod != 'Cash on Delivery') {
      status = 'pending_ewallet';
      statusLabel = '⏳ Verify $_selectedPaymentMethod';
    }

    final bool hasCustomCake = widget.cartItems.any(
      (item) => item.category.toLowerCase() == 'cakes',
    );
    if (hasCustomCake) {
      status = 'pending_spec_review';
      statusLabel = '🎂 Needs Spec Review';
    }

    final String deliverySpeedLabel = _isStandardDelivery
        ? 'Standard Delivery (25-35 mins)'
        : 'Scheduled Fresh Batch';

    final String rawPhone = _phoneController.text.trim();
    final String completePhone = rawPhone.startsWith('+63')
        ? rawPhone
        : '+63 $rawPhone';

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'id': orderId,
        'customer': _fullNameController.text.trim().isEmpty
            ? (widget.currentUser ?? 'Online Guest')
            : _fullNameController.text.trim(),
        'contact': completePhone,
        'address': _addressController.text.trim(),
        'item': itemizedSummary,
        'specs': deliverySpeedLabel,
        'referenceNumber': _refNumberController.text.trim().isEmpty
            ? null
            : _refNumberController.text.trim(),
        'note': _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        'total': '₱${calculatedGrandTotal.toStringAsFixed(2)}',
        'subtotal': widget.totalAmount,
        'deliveryFee': activeDeliveryFee,
        'packagingFee': _packagingFee,
        'status': status,
        'statusLabel': statusLabel,
        'payment': _selectedPaymentMethod,
        'isCustom': hasCustomCake,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      widget.onOrderSuccess(
        orderId,
        widget.cartItems.length,
        calculatedGrandTotal,
        _selectedPaymentMethod,
      );
      Navigator.pop(context);
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
            color: const Color(0xFFFDFBF7),
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
              final bool enableCod = data['enableCod'] ?? true;
              final bool enableEwallet = data['enableEwallet'] ?? true;

              final String gcashQr =
                  data['gcashQrUrl'] ?? 'assets/images/gcash_qr.png';
              final String qrphQr =
                  data['qrphQrUrl'] ?? 'assets/images/qrph_qr.png';

              final double standardDeliveryFee =
                  (data['standardDeliveryFee'] ?? data['deliveryFee'] ?? 80.0)
                      .toDouble();
              final double scheduledDeliveryFee =
                  (data['scheduledDeliveryFee'] ?? 70.0).toDouble();
              final double freeDeliveryThreshold =
                  (data['freeDeliveryMin'] ?? 1000.0).toDouble();

              final bool isFreeDelivery =
                  widget.totalAmount >= freeDeliveryThreshold;

              final double selectedBaseFee = _isStandardDelivery
                  ? standardDeliveryFee
                  : scheduledDeliveryFee;

              final double effectiveDeliveryFee = isFreeDelivery
                  ? 0.0
                  : selectedBaseFee;

              final double grandTotal =
                  widget.totalAmount + effectiveDeliveryFee + _packagingFee;

              if (!enableEwallet &&
                  _selectedPaymentMethod != 'Cash on Delivery') {
                _selectedPaymentMethod = 'Cash on Delivery';
              } else if (!enableCod &&
                  _selectedPaymentMethod == 'Cash on Delivery') {
                _selectedPaymentMethod = 'GCash';
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
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
                                Icons.delivery_dining_outlined,
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

                  if (!isStoreOpen)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: const Color(0xFFFDE8E8),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_clock,
                            size: 16,
                            color: Color(0xFFC62828),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bakery orders are currently paused by the kitchen admin.',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC62828),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Form Body
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

                            // Recipient Name
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
                                enabledBorder: OutlineInputBorder(
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

                            // Phone
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
                                enabledBorder: OutlineInputBorder(
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

                            // Address
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
                                enabledBorder: OutlineInputBorder(
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

                            // Delivery Speed Responsive Layout
                            _sectionLabel('DELIVERY SPEED'),
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, boxConstraints) {
                                final bool stackCards =
                                    boxConstraints.maxWidth < 360;

                                if (stackCards) {
                                  return Column(
                                    children: [
                                      _deliveryOptionCard(
                                        title: 'Standard Delivery (25-35 mins)',
                                        priceText: isFreeDelivery
                                            ? 'FREE'
                                            : '₱${standardDeliveryFee.toStringAsFixed(2)}',
                                        isSelected: _isStandardDelivery,
                                        isFree: isFreeDelivery,
                                        onTap: () => setState(
                                          () => _isStandardDelivery = true,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _deliveryOptionCard(
                                        title: 'Scheduled Fresh Batch',
                                        priceText: isFreeDelivery
                                            ? 'FREE'
                                            : '₱${scheduledDeliveryFee.toStringAsFixed(2)}',
                                        isSelected: !_isStandardDelivery,
                                        isFree: isFreeDelivery,
                                        onTap: () => setState(
                                          () => _isStandardDelivery = false,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: _deliveryOptionCard(
                                        title: 'Standard Delivery (25-35 mins)',
                                        priceText: isFreeDelivery
                                            ? 'FREE'
                                            : '₱${standardDeliveryFee.toStringAsFixed(2)}',
                                        isSelected: _isStandardDelivery,
                                        isFree: isFreeDelivery,
                                        onTap: () => setState(
                                          () => _isStandardDelivery = true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _deliveryOptionCard(
                                        title: 'Scheduled Fresh Batch',
                                        priceText: isFreeDelivery
                                            ? 'FREE'
                                            : '₱${scheduledDeliveryFee.toStringAsFixed(2)}',
                                        isSelected: !_isStandardDelivery,
                                        isFree: isFreeDelivery,
                                        onTap: () => setState(
                                          () => _isStandardDelivery = false,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            _sectionLabel('PAYMENT METHOD'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (enableEwallet) ...[
                                  _paymentChip(
                                    'GCash',
                                    Icons.account_balance_wallet_outlined,
                                  ),
                                  _paymentChip(
                                    'QRPh',
                                    Icons.qr_code_scanner_outlined,
                                  ),
                                ],
                                if (enableCod)
                                  _paymentChip(
                                    'Cash on Delivery',
                                    Icons.payments_outlined,
                                  ),
                              ],
                            ),

                            // QR Image Card
                            if (_selectedPaymentMethod !=
                                'Cash on Delivery') ...[
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
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8E4A23),
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Official $_selectedPaymentMethod Merchant QR',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2E1B10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5D5C5),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 140,
                                          height: 140,
                                          child: _buildQrImage(
                                            _selectedPaymentMethod == 'GCash'
                                                ? gcashQr
                                                : qrphQr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _selectedPaymentMethod == 'GCash'
                                          ? 'Scan with GCash app • Total: ₱${grandTotal.toStringAsFixed(2)}'
                                          : 'Scan with MariBank, SeaBank, or any QRPh app (₱${grandTotal.toStringAsFixed(2)})',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF756256),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _refNumberController,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        labelText:
                                            'Payment Reference No. (Optional)',
                                        hintText: 'e.g. 1029384756',
                                        prefixIcon: const Icon(
                                          Icons.receipt_long,
                                          size: 16,
                                          color: Color(0xFF8E4A23),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFEFE4D6),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFEFE4D6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

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
                                    'e.g. Leave at guardhouse, ring doorbell...',
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
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEFE4D6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

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
                                    'Delivery Fee',
                                    isFreeDelivery
                                        ? 'FREE (₱0.00)'
                                        : '₱${effectiveDeliveryFee.toStringAsFixed(2)}',
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
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 10,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Paying with $_selectedPaymentMethod',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF756256),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₱${grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
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
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: (_isSubmitting || !isStoreOpen)
                                ? null
                                : () => _handlePlaceOrder(
                                    activeDeliveryFee: effectiveDeliveryFee,
                                    calculatedGrandTotal: grandTotal,
                                    isStoreOpen: isStoreOpen,
                                  ),
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
                                  ? 'Placing Order...'
                                  : 'Place Sweet Order',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
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
    required String title,
    required String priceText,
    required bool isSelected,
    required bool isFree,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF2E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8E4A23)
                : const Color(0xFFEFE4D6),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E1B10),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              priceText,
              style: TextStyle(
                fontSize: 11.5,
                color: isFree
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF8E4A23),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentChip(String labelName, IconData icon) {
    // Map short label back to your full logic string if needed, or keep it clean
    final bool isSelected = _selectedPaymentMethod.startsWith(labelName);

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : const Color(0xFF8E4A23),
      ),
      label: Text(labelName),
      selected: isSelected,
      selectedColor: const Color(0xFF8E4A23),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF2E1B10),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        fontSize: 11,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            // If they select QRPh, set it cleanly
            _selectedPaymentMethod = labelName == 'QRPh'
                ? 'QRPh (MariBank/SeaBank)'
                : labelName;
          });
        }
      },
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
