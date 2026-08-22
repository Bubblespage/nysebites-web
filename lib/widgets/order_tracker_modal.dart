import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.all(24),
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
          // Directly listen to the document path using orderNumber as the Document ID
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .doc(orderNumber)
                .snapshots(),
            builder: (context, snapshot) {
              Map<String, dynamic> data = {};

              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.exists) {
                data = snapshot.data!.data() ?? {};
              }

              final String status = (data['status'] ?? 'pending_cod')
                  .toString()
                  .toLowerCase()
                  .trim();
              final String statusLabel =
                  (data['statusLabel'] ?? 'Order Sent to Kitchen').toString();
              final String payment = (data['payment'] ?? 'Cash on Delivery')
                  .toString();
              final String riderName =
                  (data['riderName'] ?? 'Assigning kitchen rider...')
                      .toString();

              final cleanStatus = status.replaceAll(' ', '_');

              // Pipeline flags
              const bool isSent = true;
              final bool isBaking =
                  cleanStatus == 'baking' ||
                  cleanStatus == 'ready_to_bake' ||
                  cleanStatus == 'preparing' ||
                  cleanStatus == 'in_kitchen' ||
                  cleanStatus == 'delivering' ||
                  cleanStatus == 'delivered';
              final bool isDelivering =
                  cleanStatus == 'delivering' || cleanStatus == 'delivered';
              final bool isDelivered = cleanStatus == 'delivered';

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF8E4A23),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text(
                              'Live Kitchen Tracker',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
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
                    const SizedBox(height: 16),

                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF2E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8D5C4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sync,
                            color: Color(0xFF8E4A23),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8E4A23),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Timeline Container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFE4D6)),
                      ),
                      child: Column(
                        children: [
                          _buildTrackingStep(
                            Icons.receipt_long_outlined,
                            'Order Received',
                            'Paid via $payment • Queue confirmed',
                            isSent,
                          ),
                          _buildStepConnector(isBaking),
                          _buildTrackingStep(
                            Icons.cookie_outlined,
                            'Baking & Packing',
                            'Artisanal batch inside the deck oven',
                            isBaking,
                          ),
                          _buildStepConnector(isDelivering),
                          _buildTrackingStep(
                            Icons.delivery_dining_outlined,
                            'Out for Delivery',
                            riderName,
                            isDelivering,
                          ),
                          _buildStepConnector(isDelivered),
                          _buildTrackingStep(
                            Icons.home_outlined,
                            'Delivered & Enjoyed',
                            'Fresh bakes received',
                            isDelivered,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Summary Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$itemCount items • PHP ${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Color(0xFF756256),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Close Tracker',
                            style: TextStyle(
                              color: Color(0xFF8E4A23),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 17),
      height: 18,
      width: 2,
      color: isActive ? const Color(0xFF8E4A23) : const Color(0xFFE5D5C5),
    );
  }

  Widget _buildTrackingStep(
    IconData icon,
    String title,
    String subtitle,
    bool isDone,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF8E4A23) : const Color(0xFFF0E5DA),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDone ? Colors.white : const Color(0xFF9E8E84),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isDone
                      ? const Color(0xFF2E1B10)
                      : const Color(0xFF9E8E84),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF756256)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

