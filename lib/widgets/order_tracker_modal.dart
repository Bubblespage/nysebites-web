import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'gcash_portal_modal.dart';
// ── FIX: Removed StorageUploader because Firebase Storage is locked behind a billing wall

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

  String? _localStatus;
  String? _localStatusLabel;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void dispose() {
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

  void _showContactAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEFE4D6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3C2216).withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEBE4),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEFE4D6)),
                  ),
                  child: const Icon(
                    Icons.phone_in_talk_rounded,
                    color: Color(0xFF8E4A23),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Kitchen Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E1B10),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Need help with your delivery? Give us a ring and we’ll sort it out fresh! 🥨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF756256),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    final Uri telUri = Uri.parse('tel:09950829180');
                    if (await canLaunchUrl(telUri)) {
                      await launchUrl(telUri);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF2E9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8D5C4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.call_rounded, size: 16, color: Color(0xFF8E4A23)),
                        SizedBox(width: 10),
                        Text(
                          '0995 082 9180',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E1B10),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E4A23),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── FIX: UNIFIED PAYMENT PROCESSOR TO PREVENT INFINITE LOADING AND USE BASE64 ──
  Future<void> _processPayment({
    required String? ref,
    required Uint8List? screenshot,
    required String stepKey,
    required String statusValue,
    required String statusLabelValue,
    required String referenceField,
    required String proofField,
  }) async {
    setState(() {
      _localStatus = statusValue;
      _localStatusLabel = statusLabelValue;
    });

    try {
      String? base64Image;

      // Encode directly to text to bypass Firebase Storage completely
      if (screenshot != null) {
        base64Image = base64Encode(screenshot);
      }

      final updateData = <String, dynamic>{
        'status': statusValue,
        'statusLabel': statusLabelValue,
      };

      if (ref != null && ref.isNotEmpty) {
        updateData[referenceField] = ref;
      }
      if (base64Image != null) {
        updateData[proofField] = base64Image;
      }
      if (stepKey == 'retainer' || stepKey == 'full') {
        updateData['paymentType'] = stepKey;
      }

      // Safe Firestore upload with a timeout to catch network hangs
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderNumber)
          .set(updateData, SetOptions(merge: true))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Database update timed out. Check network connection.'),
          );

    } catch (e) {
      debugPrint('Payment update failed: $e');
      setState(() {
        _localStatus = null; // Revert optimistic UI on failure
      });
      rethrow; // Forces the GCash modal to catch the error and STOP loading
    }
  }
  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} at $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: screenHeight * 0.90,
        ),
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
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _orderStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Stream Error: ${snapshot.error}');
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
                  case 'baked_payment_required':
                  case 'baked_payment_verifying':
                    return 5;
                  case 'delivering':
                    return 6;
                  case 'delivered':
                    return 7;
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
                            statusLabel.replaceAll('Packing', 'Preparation'),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F5F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8D5C4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E1B10))),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Order #${widget.orderNumber} • ${_formatDate(widget.placedAt)}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF9E8E84)),
                                  ),
                                ],
                              ),
                              Text('₱${widget.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8E4A23))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (data['item'] ?? '${widget.itemCount} items').toString(),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF756256), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Close Tracker',
                          style: TextStyle(
                            color: Color(0xFF8E4A23),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
  bool isDone, {
  Widget? child, // ADDED
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start, // changed from default center so the child below doesn't look squished
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
            if (child != null) child, // ADDED
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
  child: isDelivering && !isDelivered
      ? Padding(
          padding: const EdgeInsets.only(top: 12),
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
                _showContactAdminDialog(context);
              },
              icon: const Icon(Icons.phone_in_talk_outlined, size: 16),
              label: const Text('Contact Kitchen Admin'),
            ),
          ),
        )
      : null,
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
    final bool isQuote =
        cleanStatus == 'quote_received' ||
        cleanStatus == 'contract_signed' ||
        cleanStatus == 'pending_retainer_verification' ||
        cleanStatus == 'ready_to_bake' ||
        cleanStatus == 'baking' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isContract =
        cleanStatus == 'contract_signed' ||
        cleanStatus == 'pending_retainer_verification' ||
        cleanStatus == 'ready_to_bake' ||
        cleanStatus == 'baking' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isDownPayment =
        cleanStatus == 'pending_retainer_verification' ||
        cleanStatus == 'ready_to_bake' ||
        cleanStatus == 'baking' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isBaking =
        cleanStatus == 'baking' ||
        cleanStatus == 'baked_payment_required' ||
        cleanStatus == 'baked_payment_verifying' ||
        cleanStatus == 'delivering' ||
        cleanStatus == 'delivered';
    final bool isBakedPayment =
        cleanStatus == 'baked_payment_required' ||
        cleanStatus == 'baked_payment_verifying' ||
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

    final bool isFullyPaid = data['paymentType'] == 'full';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                          Expanded(
                            child: Text(
                              (data['item'] ?? 'Custom Cake').toString(),
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                        'Payment Options:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Retainer Required to Secure Slot: ₱${downPayment.toStringAsFixed(2)} (50%)',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Or Full Settlement: ₱${total.toStringAsFixed(2)} (100%)',
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
          isActive: false,
        ),
        _buildStepConnector(isDownPayment),
        _buildActionableStep(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Awaiting Payment',
          subtitle: 'Please settle your retainer or full balance to reserve your slot.',
          isDone: isDownPayment,
          isActive: cleanStatus == 'contract_signed' || cleanStatus == 'pending_retainer_verification',
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
                        'Order Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (data['item'] ?? 'Custom Cake').toString(),
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('₱${baseCakePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Custom Materials & Add-ons', style: TextStyle(fontSize: 11)),
                          Text('₱${customAddonPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(color: Color(0xFFE8D5C4)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Selection: GCash',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choose your preferred payment method. Scan the QR code to pay securely and reserve your slot.',
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0053E0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            GCashPortalModal.show(
                              context: context,
                              amount: downPayment,
                              qrAssetPath: 'assets/images/qr_code.jpg',
                              onSubmit: (ref, screenshot) => _processPayment(
                                ref: ref,
                                screenshot: screenshot,
                                stepKey: 'retainer',
                                statusValue: 'pending_retainer_verification',
                                statusLabelValue: '⏳ Verifying Retainer',
                                referenceField: 'downPaymentReference',
                                proofField: 'downpaymentProofBase64', // Note the Base64 field name
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 20),
                          label: const Text('Pay 50% Retainer (GCash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0053E0),
                            side: const BorderSide(color: Color(0xFF0053E0), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            GCashPortalModal.show(
                              context: context,
                              amount: total,
                              qrAssetPath: 'assets/images/qr_code.jpg',
                              onSubmit: (ref, screenshot) => _processPayment(
                                ref: ref,
                                screenshot: screenshot,
                                stepKey: 'full',
                                statusValue: 'pending_retainer_verification',
                                statusLabelValue: '⏳ Verifying Full Payment',
                                referenceField: 'fullPaymentReference',
                                proofField: 'fullPaymentProofBase64',
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 20),
                          label: const Text('Pay Full Amount (GCash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        _buildStepConnector(isBaking),
        _buildActionableStep(
          icon: Icons.cookie_outlined,
          title: 'Baking & Preparation',
          subtitle: 'Your custom cake is currently being baked fresh and hand-decorated by our expert bakers.',
          isDone: isBaking,
          isActive: cleanStatus == 'baking',
        ),
        _buildStepConnector(isBakedPayment),
        _buildActionableStep(
          icon: Icons.receipt_long_outlined,
          title: isFullyPaid ? 'Baked to Perfection' : 'Baked & Final Balance',
          subtitle: isFullyPaid
              ? 'Your cake is baked to perfection and ready for dispatch!'
              : 'Your cake is baked to perfection! Please settle the final balance before delivery.',
          isDone: isBakedPayment,
          isActive: cleanStatus == 'baked_payment_required',
          child: cleanStatus == 'baked_payment_required'
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
                      const Text('Scan to pay final balance:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0053E0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            GCashPortalModal.show(
                              context: context,
                              amount: balance,
                              qrAssetPath: 'assets/images/qr_code.jpg',
                              onSubmit: (ref, screenshot) => _processPayment(
                                ref: ref,
                                screenshot: screenshot,
                                stepKey: 'balance',
                                statusValue: 'baked_payment_verifying',
                                statusLabelValue: '⏳ Verifying Final Payment',
                                referenceField: 'balanceReference',
                                proofField: 'finalPaymentProofBase64',
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 20),
                          label: const Text('Pay Final Balance via GCash', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
          subtitle: 'Your custom cake is safely packed and out for delivery straight to your doorstep!',
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        _showContactAdminDialog(context);
                      },
                      icon: const Icon(Icons.phone_in_talk_outlined, size: 16),
                      label: const Text('Contact Kitchen Admin'),
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
          child: Icon(icon, size: 18, color: isDone ? Colors.white : const Color(0xFF9E8E84)),
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
                  color: isDone ? const Color(0xFF2E1B10) : const Color(0xFF9E8E84),
                ),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF756256))),
              if (child != null) child,
            ],
          ),
        ),
      ],
    );
  }
}