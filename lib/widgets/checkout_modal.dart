import 'package:flutter/material.dart';
import '../models/product.dart';

class CheckoutModal extends StatefulWidget {
  final List<Product> cartItems;
  final double totalAmount;
  final String? currentUser;
  final VoidCallback onOrderSuccess;

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
  int _currentStep = 0; // 0 = Checkout Details, 1 = Live Grab-style Tracking

  // Form Fields
  final TextEditingController _addressController = TextEditingController(
    text: 'Unit 4B, Acacia Residences, Imus, Cavite',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+63 917 849 2026',
  );
  final TextEditingController _noteController = TextEditingController();

  String _selectedPaymentMethod = 'GCash';
  String _deliveryType = 'Standard Delivery (25-35 mins)';
  final double _deliveryFee = 49.0;
  final double _packagingFee = 15.0;

  double get _grandTotal => widget.totalAmount + _deliveryFee + _packagingFee;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handlePlaceOrder() {
    setState(() => _currentStep = 1);
    widget.onOrderSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 780),
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
          child: _currentStep == 0
              ? _buildCheckoutReviewForm()
              : _buildLiveTrackingView(),
        ),
      ),
    );
  }

  // STEP 1: Grab-style Checkout Breakdown & Details
  Widget _buildCheckoutReviewForm() {
    return Column(
      children: [
        // Modal Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF2E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delivery_dining_outlined,
                      color: Color(0xFF8E4A23),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Review & Checkout',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E1B10),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF756256)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFEFE4D6), height: 1),

        // Body Sections
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Delivery Address Card
                _sectionLabel('DELIVERY ADDRESS'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEFE4D6)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF8E4A23),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _addressController,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E1B10),
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Enter complete drop-off address',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFF3E7DC), height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_iphone,
                            color: Color(0xFF8E4A23),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF756256),
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Contact number for rider',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Delivery Options
                _sectionLabel('DELIVERY SPEED'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _deliveryOptionPill(
                      'Standard Delivery (25-35 mins)',
                      '₱61.00',
                    ),
                    _deliveryOptionPill('Scheduled Fresh Batch', '₱49.00'),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Payment Method
                _sectionLabel('PAYMENT METHOD'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _paymentChip(
                      'GCash',
                      Icons.account_balance_wallet_outlined,
                    ),
                    _paymentChip('Maya', Icons.credit_card_outlined),
                    _paymentChip('Cash on Delivery', Icons.payments_outlined),
                    _paymentChip('Debit/Credit Card', Icons.payment_outlined),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Note to Kitchen & Rider
                _sectionLabel('RIDER / BAKE NOTES'),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF2E1B10),
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Leave at lobby guard, knock softly...',
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
                      borderSide: const BorderSide(color: Color(0xFFEFE4D6)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFEFE4D6)),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // 5. Bill Summary Breakdown
                _sectionLabel('PAYMENT BREAKDOWN'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEFE4D6)),
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
                        '₱${_deliveryFee.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 6),
                      _receiptRow(
                        'Bakery Eco Seal Packaging',
                        '₱${_packagingFee.toStringAsFixed(2)}',
                      ),
                      const Divider(color: Color(0xFFEFE4D6), height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF2E1B10),
                            ),
                          ),
                          Text(
                            '₱${_grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
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

        // Action Bottom Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEFE4D6))),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(23)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Paying with $_selectedPaymentMethod',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF756256),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₱${_grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 19,
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
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _handlePlaceOrder,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    'Place Sweet Order',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: Live Grab-Style Order Placed Status
  Widget _buildLiveTrackingView() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF2E9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8E4A23), width: 2),
            ),
            child: const Icon(
              Icons.restaurant,
              size: 42,
              color: Color(0xFF8E4A23),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Order Confirmed & Baking!',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E1B10),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estimated delivery: 25 - 35 minutes to ${_addressController.text.split(",").first}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF756256)),
          ),
          const SizedBox(height: 24),

          // Grab Tracking Stepper Timeline
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEFE4D6)),
            ),
            child: Column(
              children: [
                _trackingStep(
                  Icons.check_circle,
                  'Order Sent to Oven',
                  'Nyse Bites kitchen received the batch',
                  true,
                ),
                const SizedBox(height: 12),
                _trackingStep(
                  Icons.cookie,
                  'Freshly Baking & Packing',
                  'Artisanal bakes in oven now',
                  true,
                ),
                const SizedBox(height: 12),
                _trackingStep(
                  Icons.delivery_dining,
                  'Rider Delivery',
                  'Assigned sweet delivery rider',
                  false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E1B10),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to Fresh Menu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

  Widget _deliveryOptionPill(String title, String price) {
    final isSelected = _deliveryType == title;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _deliveryType = title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E1B10),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF8E4A23),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentChip(String name, IconData icon) {
    final isSelected = _selectedPaymentMethod == name;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : const Color(0xFF8E4A23),
      ),
      label: Text(name),
      selected: isSelected,
      selectedColor: const Color(0xFF8E4A23),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF2E1B10),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedPaymentMethod = name);
      },
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF756256)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E1B10),
          ),
        ),
      ],
    );
  }

  Widget _trackingStep(IconData icon, String title, String desc, bool isDone) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDone ? const Color(0xFF8E4A23) : const Color(0xFFC7B198),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDone
                    ? const Color(0xFF2E1B10)
                    : const Color(0xFF9E8E84),
              ),
            ),
            Text(
              desc,
              style: const TextStyle(fontSize: 11, color: Color(0xFF756256)),
            ),
          ],
        ),
      ],
    );
  }
}
