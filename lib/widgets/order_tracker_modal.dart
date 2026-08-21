import 'package:flutter/material.dart';

class OrderTrackerModal extends StatelessWidget {
  final String orderNumber;
  final int itemCount;
  final double totalAmount;
  final DateTime placedAt;

  const OrderTrackerModal({
    super.key,
    required this.orderNumber,
    required this.itemCount,
    required this.totalAmount,
    required this.placedAt,
  });

  @override
  Widget build(BuildContext context) {
    final elapsedMinutes = DateTime.now().difference(placedAt).inMinutes;
    final activeStep = elapsedMinutes >= 20 ? 2 : 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEFE4D6)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(60, 34, 22, 0.2),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF2E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: Color(0xFF8E4A23),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Track Your Sweet Order',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E1B10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF756256)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E1B10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryValue('ORDER', orderNumber, Colors.white),
                      _summaryValue('ITEMS', '$itemCount', Colors.white),
                      _summaryValue(
                        'TOTAL',
                        '₱${totalAmount.toStringAsFixed(2)}',
                        Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Live order status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E1B10),
                  ),
                ),
                const SizedBox(height: 14),
                _statusStep(
                  Icons.check_circle,
                  'Order received',
                  'Nyse Bites has your order.',
                  true,
                  false,
                ),
                _statusStep(
                  Icons.cookie,
                  'Freshly baking & packing',
                  'Your treats are being prepared.',
                  true,
                  false,
                ),
                _statusStep(
                  Icons.delivery_dining,
                  'Rider delivery',
                  activeStep == 2
                      ? 'Your order is being sent your way.'
                      : 'A rider will be assigned after baking.',
                  activeStep == 2,
                  true,
                ),
                const SizedBox(height: 18),
                Text(
                  'Placed ${_placedLabel(placedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF756256),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryValue(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.65),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _statusStep(
    IconData icon,
    String title,
    String subtitle,
    bool isComplete,
    bool isLast,
  ) {
    final color = isComplete
        ? const Color(0xFF8E4A23)
        : const Color(0xFFB9A99D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  color: isComplete
                      ? const Color(0xFFD9B99F)
                      : const Color(0xFFEFE4D6),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isComplete
                        ? const Color(0xFF2E1B10)
                        : const Color(0xFF756256),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF756256),
                  ),
                ),
                if (!isLast) const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _placedLabel(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes == 1) return '1 minute ago';
    return '${difference.inMinutes} minutes ago';
  }
}
