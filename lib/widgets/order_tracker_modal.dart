import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackerModal extends StatefulWidget {
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
  State<OrderTrackerModal> createState() => _OrderTrackerModalState();
}

class _OrderTrackerModalState extends State<OrderTrackerModal> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _orderStream;
  bool _isManualRefresh = false;

  final TextEditingController _downPaymentRefController =
      TextEditingController();
  final TextEditingController _balanceRefController = TextEditingController();

  String? _localStatus;
  String? _localStatusLabel;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void dispose() {
    _downPaymentRefController.dispose();
    _balanceRefController.dispose();
    super.dispose();
  }

  void _initStream() {
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderNumber)
        .snapshots();
  }

  void _manualRefresh() {
    setState(() {
      _isManualRefresh = true;
      _initStream();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isManualRefresh = false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing live kitchen pipeline...'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

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
            stream: _orderStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Stream Error: ${snapshot.error}');
                // Fallthrough to use last known data instead of returning an error screen
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData &&
                  !_isManualRefresh) {
                return const SizedBox(
                  height: 250,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF8E4A23)),
                  ),
                );
              }

              Map<String, dynamic> data = {};
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.exists) {
                data = snapshot.data!.data() ?? {};
              }

              String dbStatus = (data['status'] ?? 'pending_cod')
                  .toString()
                  .toLowerCase()
                  .trim();
              String dbStatusLabel =
                  (data['statusLabel'] ?? 'Order Sent to Kitchen').toString();

              int getStatusRank(String s) {
                switch (s) {
                  case 'pending_spec_review':
                    return 0;
                  case 'quote_received':
                    return 1;
                  case 'contract_signed':
                    return 2;
                  case 'ready_to_bake':
                    return 3;
                  case 'baking':
                  case 'preparing':
                  case 'in_kitchen':
                    return 4;
                  case 'delivering':
                    return 5;
                  case 'delivered':
                    return 6;
                  default:
                    return -1;
                }
              }

              String status = dbStatus;
              String statusLabel = dbStatusLabel;

              if (_localStatus != null) {
                if (getStatusRank(_localStatus!) > getStatusRank(dbStatus)) {
                  status = _localStatus!;
                  statusLabel = _localStatusLabel ?? dbStatusLabel;
                }
              }

              final String payment =
                  (data['payment'] ??
                          data['paymentMethod'] ??
                          data['method'] ??
                          'GCash')
                      .toString();

              final String riderName =
                  (data['riderName'] ?? 'Assigning GrabCar driver...')
                      .toString();

              final bool isCustom = data['isCustom'] ?? false;
              final cleanStatus = status.replaceAll(' ', '_');

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.orderNumber,
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
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Color(0xFF8E4A23),
                                size: 20,
                              ),
                              tooltip: 'Force Sync Stream',
                              onPressed: _manualRefresh,
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
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFE4D6)),
                      ),
                      child: isCustom
                          ? _buildCustomTrackerFlow(
                              data,
                              cleanStatus,
                              payment,
                              riderName,
                            )
                          : _buildStandardTrackerFlow(
                              cleanStatus,
                              payment,
                              riderName,
                            ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.itemCount} items • ₱${widget.totalAmount.toStringAsFixed(2)}',
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

  Widget _buildStandardTrackerFlow(
    String cleanStatus,
    String payment,
    String riderName,
  ) {
    const bool isSent = true;
    final bool isBaking =
        cleanStatus == 'baking' ||
        cleanStatus == 'preparing' ||
        cleanStatus == 'in_kitchen' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isDelivering =
        cleanStatus == 'delivering' || cleanStatus == 'delivered';
    final bool isDelivered = cleanStatus == 'delivered';

    return Column(
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
          'Baking & Preparation',
          'Artisanal batch inside the deck oven',
          isBaking,
        ),
        _buildStepConnector(isDelivering),
        _buildTrackingStep(
          Icons.local_taxi_outlined,
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
    );
  }

  Widget _buildCustomTrackerFlow(
    Map<String, dynamic> data,
    String cleanStatus,
    String payment,
    String riderName,
  ) {
    // Determine milestone booleans
    final bool isQuote =
        cleanStatus == 'quote_received' ||
        cleanStatus == 'contract_signed' ||
        cleanStatus == 'ready_to_bake' ||
        cleanStatus == 'baking' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isContract =
        cleanStatus == 'contract_signed' ||
        cleanStatus == 'ready_to_bake' ||
        cleanStatus == 'baking' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isDownPayment =
        cleanStatus == 'ready_to_bake' ||
        cleanStatus == 'baking' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isBaking =
        cleanStatus == 'baking' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isDelivering =
        cleanStatus == 'delivering' || cleanStatus == 'delivered';
    final bool isDelivered = cleanStatus == 'delivered';

    final double baseCakePrice =
        double.tryParse((data['baseCakePrice'] ?? 6500.0).toString()) ?? 6500.0;
    final double customAddonPrice =
        double.tryParse((data['customAddonPrice'] ?? 300.0).toString()) ??
        300.0;
    final double total = baseCakePrice + customAddonPrice;
    final double downPayment =
        double.tryParse((data['downPayment'] ?? (total / 2)).toString()) ??
        (total / 2);
    final double balance =
        double.tryParse((data['balance'] ?? (total / 2)).toString()) ??
        (total / 2);

    return Column(
      children: [
        _buildActionableStep(
          icon: Icons.receipt_long_outlined,
          title: 'Inquiry Sent / Received',
          subtitle:
              'We are reviewing your custom cake request and will prepare an itemized quote shortly. Hang tight!',
          isDone: true,
          isActive: cleanStatus == 'pending_spec_review',
        ),
        _buildStepConnector(isQuote),
        _buildActionableStep(
          icon: Icons.request_quote_outlined,
          title: 'Quote Received',
          subtitle: 'Reviewing the itemized quote before contract signing.',
          isDone: isQuote,
          isActive: cleanStatus == 'quote_received',
          child: cleanStatus == 'quote_received'
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8D5C4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Itemized Pricing Breakdown:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Base Design',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '₱${baseCakePrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Custom Materials & Add-ons',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '₱${customAddonPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE8D5C4)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '₱${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Payment Terms:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Down Payment Due Now: ₱${downPayment.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Balance Due: ₱${balance.toStringAsFixed(2)} (Due 2 weeks before delivery)',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E4A23),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _localStatus = 'contract_signed';
                              _localStatusLabel = '✅ Contract Signed';
                            });
                            try {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(widget.orderNumber)
                                  .set({
                                    'status': 'contract_signed',
                                    'statusLabel': '✅ Contract Signed',
                                  }, SetOptions(merge: true));
                            } catch (e) {
                              debugPrint('Optimistic update failed: $e');
                            }
                          },
                          child: const Text(
                            'Accept Quote & Sign Digital Contract',
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        _buildStepConnector(isContract),
        _buildActionableStep(
          icon: Icons.draw_outlined,
          title: 'Contract Signed',
          subtitle: 'Digital contract signed and agreed upon.',
          isDone: isContract,
          isActive: cleanStatus == 'contract_signed',
          child: cleanStatus == 'contract_signed'
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8D5C4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Selection: GCash',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Scan the QR code to securely pay the down payment and secure your delivery slot.',
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFF007DFE,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.qr_code_2,
                                size: 64,
                                color: Color(0xFF007DFE),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₱${downPayment.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF007DFE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _downPaymentRefController,
                        decoration: InputDecoration(
                          hintText: 'Enter 13-digit Reference No.',
                          hintStyle: const TextStyle(fontSize: 11),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8D5C4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007DFE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_downPaymentRefController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter reference number',
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _localStatus = 'ready_to_bake';
                              _localStatusLabel = '💰 Down Payment Paid';
                            });
                            try {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(widget.orderNumber)
                                  .set({
                                    'downPaymentReference':
                                        _downPaymentRefController.text.trim(),
                                    'status': 'ready_to_bake',
                                    'statusLabel': '💰 Down Payment Paid',
                                  }, SetOptions(merge: true));
                            } catch (e) {
                              debugPrint('Optimistic update failed: $e');
                            }
                          },
                          child: const Text('Submit Payment Reference'),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        _buildStepConnector(isDownPayment),
        _buildActionableStep(
          icon: Icons.payments_outlined,
          title: 'Down Payment Paid',
          subtitle:
              'Down payment received. We have secured your baking slot and are preparing for your sweet celebration!',
          isDone: isDownPayment,
          isActive: cleanStatus == 'ready_to_bake',
        ),
        _buildStepConnector(isBaking),
        _buildActionableStep(
          icon: Icons.cookie_outlined,
          title: 'Baking & Preparation',
          subtitle:
              'Your custom cake is currently being baked fresh and hand-decorated by our expert bakers.',
          isDone: isBaking,
          isActive: cleanStatus == 'baking',
          child: cleanStatus == 'baking'
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8D5C4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scan to pay final balance:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFF007DFE,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.qr_code_2,
                                size: 64,
                                color: Color(0xFF007DFE),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₱${balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF007DFE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _balanceRefController,
                        decoration: InputDecoration(
                          hintText: 'Enter 13-digit Reference No.',
                          hintStyle: const TextStyle(fontSize: 11),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8D5C4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007DFE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_balanceRefController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter reference number',
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _localStatus = 'delivering';
                              _localStatusLabel = '🚗 Out for Delivery';
                            });
                            try {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(widget.orderNumber)
                                  .set({
                                    'balanceReference': _balanceRefController
                                        .text
                                        .trim(),
                                    'status': 'delivering',
                                    'statusLabel': '🚗 Out for Delivery',
                                  }, SetOptions(merge: true));
                            } catch (e) {
                              debugPrint('Optimistic update failed: $e');
                            }
                          },
                          child: const Text('Submit Payment Reference'),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        _buildStepConnector(isDelivering),
        _buildActionableStep(
          icon: Icons.local_taxi_outlined,
          title: 'Out for Delivery',
          subtitle:
              'Your custom cake is safely packed and out for delivery straight to your doorstep!',
          isDone: isDelivering,
          isActive: cleanStatus == 'delivering',
          child: cleanStatus == 'delivering'
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8E4A23)),
                        foregroundColor: const Color(0xFF8E4A23),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contacting rider...')),
                        );
                      },
                      icon: const Icon(Icons.phone_in_talk_outlined, size: 16),
                      label: const Text(
                        'Contact Delivery Rider / Kitchen Admin',
                      ),
                    ),
                  ),
                )
              : null,
        ),
        _buildStepConnector(isDelivered),
        _buildActionableStep(
          icon: Icons.home_outlined,
          title: 'Balance Paid & Delivered',
          subtitle: 'Fresh bakes received. Thank you for celebrating with us!',
          isDone: isDelivered,
          isActive: cleanStatus == 'delivered',
        ),
      ],
    );
  }

  Widget _buildActionableStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    Widget? child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              if (child != null) child,
            ],
          ),
        ),
      ],
    );
  }
}
