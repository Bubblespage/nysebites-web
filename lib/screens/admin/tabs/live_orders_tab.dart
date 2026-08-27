import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../../../utils/pdf_report_generator.dart';
import '../admin_modals.dart';

class LiveOrdersTab extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final bool isDesktop;
  final String searchQuery;
  final String
      currentRole; // 'Super Admin', 'Baker Admin', or 'Order Dispatcher'
  final Function(String id, String newStatus, String newLabel,
      [Map<String, dynamic>? extraData]) onUpdateStatus;

  const LiveOrdersTab({
    super.key,
    required this.orders,
    required this.isDesktop,
    required this.searchQuery,
    required this.currentRole,
    required this.onUpdateStatus,
  });

  @override
  State<LiveOrdersTab> createState() => _LiveOrdersTabState();
}

class _LiveOrdersTabState extends State<LiveOrdersTab> {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);
  static const Color wellBg = Color(0xFFF4EDE6);

  String _currentFilter = 'All';


  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final monthName = (dt.month >= 1 && dt.month <= 12)
          ? months[dt.month]
          : '${dt.month}';
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';

      // Using spaces and a dash instead of slashes or bullets to prevent font missing-glyph boxes
      return '$monthName ${dt.day} ${dt.year} - $hour:$minute $period';
    }
    return timestamp.toString();
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return widget.orders.where((order) {
      if (_currentFilter == 'All') return true;

      // Filter out completed and cancelled orders for the specific pipeline tabs
      final status = (order['status'] ?? '').toString().toLowerCase();
      if (status == 'delivered' || status == 'completed' || status == 'cancelled' || status == 'picked_up') {
        return false;
      }


      final targetField = order['targetDate'] ?? order['createdAt'];
      DateTime? targetDate;
      if (targetField is Timestamp) {
        targetDate = targetField.toDate();
      } else if (targetField != null) {
        targetDate = DateTime.tryParse(targetField.toString());
      }

      if (targetDate == null) {
        return _currentFilter == 'Due Today'; // Default to today if no date
      }

      final dateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);

      if (_currentFilter == 'Due Today') {
        return dateOnly.isBefore(tomorrow); // Today or earlier
      } else if (_currentFilter == 'Due Tomorrow') {
        return dateOnly.isAtSameMomentAs(tomorrow);
      } else if (_currentFilter == 'Upcoming') {
        return dateOnly.isAfter(tomorrow);
      }

      return true;
    }).toList();
  }

  Widget _buildFilterButton(String title) {
    final isSelected = _currentFilter == title;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _currentFilter = title),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? brandCocoa : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? brandCocoa : borderLight),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : textMuted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // We assume _buildMetricsRow() is defined somewhere in the class or as a standalone function.
        // It's called in original code, so let's keep it if it exists, but wait, original had _buildMetricsRow().
        // If it's undefined, it will cause an error, but it must be defined further down.
        // wait, I don't see _buildMetricsRow in the snippet... Ah, it must be lower down.
        // Actually, let me just replace the build method accurately.
        _buildMetricsRow(),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderLight),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B7355).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Kitchen Pipeline',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildFilterButton('All'),
                            _buildFilterButton('Due Today'),
                            _buildFilterButton('Due Tomorrow'),
                            _buildFilterButton('Upcoming'),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (widget.searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              'Found ${filtered.length} orders',
                              style: const TextStyle(
                                fontSize: 12,
                                color: brandCocoa,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final bytes = await PdfReportGenerator.generateLiveOrdersReport(
                              filtered, 
                              filterInfo: _currentFilter,
                            );
                            final filename = 'live_orders_${_currentFilter.toLowerCase().replaceAll(' ', '_')}.pdf';
                            await Printing.sharePdf(bytes: bytes, filename: filename);
                          },
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Export PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandCocoa,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(36),
                  alignment: Alignment.center,
                  child: const Text(
                    'No orders match your filter.',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                )
              else
                widget.isDesktop
                    ? _buildDesktopTable(context, filtered)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                        child: _buildMobileList(context, filtered),
                      ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Map<String, dynamic>> filteredOrders) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFFBF7F2),
            border: Border(
              top: BorderSide(color: borderLight),
              bottom: BorderSide(color: borderLight),
            ),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 110,
                child: Text('ORDER ID', style: _headerStyle),
              ),
              SizedBox(width: 14),
              SizedBox(
                width: 155,
                child: Text('CUSTOMER', style: _headerStyle),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text('ITEMIZED DETAILS & SPECS', style: _headerStyle),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 90,
                child: Text(
                  'AMOUNT',
                  style: _headerStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 145,
                child: Text(
                  'STATUS',
                  style: _headerStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 190,
                child: Text(
                  'ACTIONS',
                  style: _headerStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredOrders.length,
          separatorBuilder: (_, __) =>
              const Divider(color: borderLight, height: 1),
          itemBuilder: (context, i) {
            final order = filteredOrders[i];
            final formattedDate = _formatTimestamp(order['createdAt']);

            return HoverElevate(
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order['id'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: darkEspresso,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 155,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order['customer'] ?? 'Online Guest',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          order['contact'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildPaymentBadge(
                          order['payment'] ?? 'Cash on Delivery',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order['item'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: textDark,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order['specs'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: textMuted,
                          ),
                        ),
                        if (order['targetTimeSlot'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: brandCocoa),
                                const SizedBox(width: 4),
                                Text(
                                  '${order['targetDate'] != null ? _formatTimestamp(order['targetDate']) + ' at ' : ''}${order['targetTimeSlot']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: brandCocoa,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (order['note'] != null &&
                            order['note'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              '✏️ "${order['note']}"',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: brandCocoa,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 90,
                    child: Text(
                      order['total'] ?? '₱0.00',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: brandCocoa,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 145,
                    child: Center(
                      child: _buildStatusPill(
                        order['statusLabel'] ?? 'Pending',
                        order['status'] ?? '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 190,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.receipt_outlined,
                            size: 18,
                            color: textDark,
                          ),
                          tooltip: 'Print Kitchen Slip',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            // Inject timestamp into print data map for physical receipts
                            final printData = Map<String, dynamic>.from(order);
                            printData['printDate'] = formattedDate;
                            AdminModals.showPrintSlipDialog(context, printData);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFD32F2F),
                          ),
                          tooltip: 'Delete Order',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showDeleteConfirmation(context, (order['id'] ?? order['docId'] ?? '').toString()),
                        ),
                        const SizedBox(width: 4),
                        _buildPrimaryStepButton(context, order),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        ),
      ],
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    color: brandCocoa,
    letterSpacing: 0.8,
  );

  Widget _buildMobileList(BuildContext context, List<Map<String, dynamic>> filteredOrders) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = filteredOrders[i];
        final formattedDate = _formatTimestamp(order['createdAt']);

        return HoverElevate(
          isMobile: true,
          child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: wellBg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderLight),
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
                      Text(
                        order['id'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: darkEspresso,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10, color: textMuted),
                      ),
                    ],
                  ),
                  Text(
                    order['total'] ?? '₱0.00',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: brandCocoa,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${order['customer'] ?? 'Online Guest'} • ${order['contact'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentBadge(order['payment'] ?? 'Cash on Delivery'),
                ],
              ),
              const Divider(color: borderLight, height: 16),
              Text(
                order['item'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: textDark,
                ),
              ),
              Text(
                order['specs'] ?? '',
                style: const TextStyle(fontSize: 11, color: textMuted),
              ),
              if (order['targetTimeSlot'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: brandCocoa),
                      const SizedBox(width: 4),
                      Text(
                        order['targetTimeSlot'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: brandCocoa,
                        ),
                      ),
                    ],
                  ),
                ),
              if (order['note'] != null && order['note'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '✏️ "${order['note']}"',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: brandCocoa,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusPill(
                    order['statusLabel'] ?? 'Pending',
                    order['status'] ?? '',
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.receipt_outlined,
                          size: 18,
                          color: textDark,
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          final printData = Map<String, dynamic>.from(order);
                          printData['printDate'] = formattedDate;
                          AdminModals.showPrintSlipDialog(context, printData);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Color(0xFFD32F2F),
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showDeleteConfirmation(context, (order['id'] ?? order['docId'] ?? '').toString()),
                      ),
                      const SizedBox(width: 4),
                      _buildPrimaryStepButton(context, order),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildPaymentBadge(String payment) {
    final cleanPay = payment.trim();
    Color bg = const Color(0xFFECEFF1);
    Color fg = const Color(0xFF455A64);

    if (cleanPay.contains('GCash')) {
      bg = const Color(0xFFE8F0FE);
      fg = const Color(0xFF1967D2);
    } else if (cleanPay.contains('QRPh') ||
        cleanPay.contains('MariBank') ||
        cleanPay.contains('SeaBank')) {
      bg = const Color(0xFFE6F4EA);
      fg = const Color(0xFF137333);
    } else if (cleanPay.contains('Delivery') || cleanPay.contains('COD')) {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        cleanPay,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildPrimaryStepButton(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final String targetDocId = (order['docId'] ?? order['id'] ?? '').toString();
    final String status = order['status'] ?? '';
    final bool isCustom = order['isCustom'] == true;
    final bool isRider = widget.currentRole == 'Order Dispatcher';

    if (isRider) {
      if (status == 'pending_ewallet' ||
          status == 'pending_cod' ||
          status == 'pending_spec_review' ||
          status == 'ready_to_bake') {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: wellBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'In Kitchen Prep',
            style: TextStyle(
              color: textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      if (status == 'baking') {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC27803),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: const Size(105, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () =>
              widget.onUpdateStatus(targetDocId, 'delivering', '🛵 Out for Delivery'),
          icon: const Icon(Icons.takeout_dining, size: 13, color: Colors.white),
          label: const Text(
            'Pick Up Batch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      if (status == 'delivering') {
        final bool isCod = (order['payment'] ?? '')
            .toString()
            .toLowerCase()
            .contains('cash');
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: const Size(105, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () => AdminModals.showRiderTrackerModal(
            context,
            order,
            () => widget.onUpdateStatus(
              targetDocId,
              'delivered',
              '✓ Completed Delivery',
            ),
          ),
          icon: const Icon(
            Icons.check_circle_outline,
            size: 13,
            color: Colors.white,
          ),
          label: Text(
            isCod ? 'Collect COD' : 'Mark Done',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      return const Text(
        '✓ Done',
        style: TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (status == 'pending_ewallet') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC27803),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => AdminModals.showPaymentVerificationModal(
          context,
          order,
          () {
            if (isCustom) {
              widget.onUpdateStatus(
                targetDocId,
                'pending_spec_review',
                '🎂 Needs Spec Review',
              );
            } else {
              widget.onUpdateStatus(targetDocId, 'ready_to_bake', '✓ Ready for Oven');
            }
          },
        ),
        child: const Text(
          'Verify Pay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'pending_cod') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6572),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => AdminModals.showPaymentVerificationModal(
          context,
          order,
          () {
            if (isCustom) {
              widget.onUpdateStatus(
                targetDocId,
                'pending_spec_review',
                '🎂 Needs Spec Review',
              );
            } else {
              widget.onUpdateStatus(targetDocId, 'ready_to_bake', '✓ Ready for Oven');
            }
          },
        ),
        child: const Text(
          'Confirm COD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'pending_spec_review') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandCocoa,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => AdminModals.showCustomCakeInspectionDrawer(
          context,
          order,
          (basePrice, addonPrice) {
            final double total = basePrice + addonPrice;
            final double downPayment = total / 2;
            final double balance = total - downPayment;
            
            widget.onUpdateStatus(
              targetDocId, 
              'quote_received', 
              '📝 Quote & Contract Sent',
              {
                'baseCakePrice': basePrice,
                'customAddonPrice': addonPrice,
                'downPayment': downPayment,
                'balance': balance,
                'total': '₱${total.toStringAsFixed(2)}',
              }
            );
          },
          () => widget.onUpdateStatus(targetDocId, 'spec_rejected', '❌ Spec Rejected'),
        ),
        icon: const Icon(Icons.cake_outlined, size: 13, color: Colors.white),
        label: const Text(
          'Inspect Spec',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'quote_received') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC27803),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => AdminModals.showPaymentVerificationModal(
          context,
          order,
          () => widget.onUpdateStatus(targetDocId, 'ready_to_bake', '✓ Ready for Oven'),
        ),
        child: const Text(
          'Verify GCash',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'ready_to_bake') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkEspresso,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () =>
            widget.onUpdateStatus(targetDocId, 'baking', '🍪 Baking & Packing'),
        child: const Text(
          'Start Bake',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'baking') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandCocoa,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () {
          if (isCustom) {
            widget.onUpdateStatus(targetDocId, 'baked_payment_required', '💳 Awaiting Balance');
          } else {
            widget.onUpdateStatus(targetDocId, 'delivering', '🛵 Out for Delivery');
          }
        },
        child: const Text(
          'Mark Baked',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'baked_payment_verifying') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC27803),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => AdminModals.showBalanceVerificationModal(
          context,
          order,
          () => widget.onUpdateStatus(targetDocId, 'delivering', '🛵 Out for Delivery'),
        ),
        child: const Text(
          'Verify Balance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'baked_payment_required') {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: null,
        child: const Text(
          'Pending Balance',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: brandCocoa),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(105, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: () => AdminModals.showRiderTrackerModal(
        context,
        order,
        () => widget.onUpdateStatus(targetDocId, 'delivered', '✓ Completed Delivery'),
      ),
      child: const Text(
        'Track Rider',
        style: TextStyle(
          color: brandCocoa,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, String status) {
    Color bg = wellBg;
    Color fg = textDark;
    if (status == 'baking') {
      bg = const Color(0xFFFBEBE4);
      fg = brandCocoa;
    } else if (status.contains('pending') || status.contains('verifying')) {
      bg = const Color(0xFFFEF6E9);
      fg = const Color(0xFFC27803);
    } else if (status == 'delivering' || status == 'baked_payment_required') {
      bg = const Color(0xFFEBF5EC);
      fg = const Color(0xFF2E7D32);
    } else if (status == 'ready_to_bake') {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  double _parseOrderAmount(dynamic amount) {
    if (amount is num) return amount.toDouble();
    if (amount is String) {
      final cleaned = amount.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  Widget _buildMetricsRow() {
    final completedOrders = widget.orders.where((o) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      final label = (o['statusLabel'] ?? '').toString().toLowerCase();
      return status == 'delivered' ||
          status == 'completed' ||
          status.contains('completed') ||
          label.contains('completed');
    }).toList();

    final double todaySales = completedOrders.fold(0.0, (totalSum, o) {
      return totalSum +
          _parseOrderAmount(o['total'] ?? o['totalAmount'] ?? o['subtotal']);
    });

    final customCakeOrders = widget.orders.where((o) {
      final bool isCustomFlag =
          o['isCustom'] == true ||
          o['isCustom']?.toString().toLowerCase() == 'true';
      final String itemName = (o['item'] ?? o['productName'] ?? '')
          .toString()
          .toLowerCase();
      final String category = (o['category'] ?? '').toString().toLowerCase();

      return isCustomFlag ||
          itemName.contains('custom') ||
          itemName.contains('cake') ||
          category.contains('cake');
    }).toList();

    final int pendingSpecsCount = customCakeOrders.where((o) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      return status.contains('pending') || status == 'received';
    }).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double cardWidth = width >= 800
            ? (width - (3 * 12)) / 4
            : (width >= 400 ? (width - 12) / 2 : width);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metricCard(
              'ACTIVE ORDERS',
              '${widget.orders.length} Batches',
              'In pipeline now',
              brandCocoa,
              cardWidth,
            ),
            _metricCard(
              'CUSTOM CAKES',
              '${customCakeOrders.length} Custom',
              pendingSpecsCount > 0
                  ? '$pendingSpecsCount need spec check'
                  : 'All specs verified',
              const Color(0xFFC27803),
              cardWidth,
            ),
            _metricCard(
              "TODAY'S SALES",
              '₱${todaySales.toStringAsFixed(2)}',
              '${completedOrders.length} orders completed',
              const Color(0xFF2E7D32),
              cardWidth,
            ),
            _metricCard(
              'NEXT DROP',
              '18m : 42s',
              'Release timer',
              darkEspresso,
              cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(
    String tag,
    String value,
    String sub,
    Color tagColor,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: tagColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10.5, color: textMuted)),
        ],
      ),
    );
  }
  void _showDeleteConfirmation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Text(
            'Delete Order?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
          ),
          content: Text(
            'Are you sure you want to permanently delete order $orderId? This action cannot be undone.',
            style: const TextStyle(color: textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order successfully deleted'), backgroundColor: Color(0xFF4CAF50)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e'), backgroundColor: const Color(0xFFD32F2F)),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class HoverElevate extends StatefulWidget {
  final Widget child;
  final bool isMobile;
  const HoverElevate({super.key, required this.child, this.isMobile = false});

  @override
  State<HoverElevate> createState() => _HoverElevateState();
}

class _HoverElevateState extends State<HoverElevate> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovering ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: widget.isMobile ? BorderRadius.circular(14) : BorderRadius.zero,
          boxShadow: _isHovering
              ? [
                  BoxShadow(
            color: const Color(0xFF8B7355).withValues(alpha: 0.08),
            blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}
