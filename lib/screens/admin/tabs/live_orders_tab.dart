import 'package:flutter/material.dart';
import '../admin_modals.dart';

class LiveOrdersTab extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final bool isDesktop;
  final String searchQuery;
  final String currentRole; // 'Super Admin', 'Baker Admin', or 'Order Dispatcher'
  final Function(String id, String newStatus, String newLabel) onUpdateStatus;

  const LiveOrdersTab({
    super.key,
    required this.orders,
    required this.isDesktop,
    required this.searchQuery,
    required this.currentRole,
    required this.onUpdateStatus,
  });

  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);
  static const Color wellBg = Color(0xFFF4EDE6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsRow(),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderLight),
            boxShadow: [
              BoxShadow(
                color: darkEspresso.withOpacity(0.03),
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
                    const Text(
                      'Live Kitchen Pipeline',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: textDark,
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      Text(
                        'Found ${orders.length} orders',
                        style: const TextStyle(
                          fontSize: 12,
                          color: brandCocoa,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (orders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(36),
                  alignment: Alignment.center,
                  child: const Text(
                    'No orders match your filter.',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                )
              else
                isDesktop
                    ? _buildDesktopTable(context)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                        child: _buildMobileList(context),
                      ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return Column(
      children: [
        // Grid Table Header
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
              SizedBox(width: 100, child: Text('ORDER ID', style: _headerStyle)),
              SizedBox(width: 14),
              SizedBox(width: 155, child: Text('CUSTOMER', style: _headerStyle)),
              SizedBox(width: 16),
              Expanded(child: Text('ITEMIZED DETAILS & SPECS', style: _headerStyle)),
              SizedBox(width: 16),
              SizedBox(width: 90, child: Text('AMOUNT', style: _headerStyle, textAlign: TextAlign.right)),
              SizedBox(width: 16),
              SizedBox(width: 145, child: Text('STATUS', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 12),
              SizedBox(width: 155, child: Text('ACTIONS', style: _headerStyle, textAlign: TextAlign.center)),
            ],
          ),
        ),
        // Grid Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const Divider(color: borderLight, height: 1),
          itemBuilder: (context, i) {
            final order = orders[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      order['id'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: darkEspresso,
                        fontSize: 12.5,
                      ),
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
                          style: const TextStyle(fontSize: 11, color: textMuted),
                        ),
                        const SizedBox(height: 4),
                        _buildPaymentBadge(order['payment'] ?? 'Cash on Delivery'),
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
                          style: const TextStyle(fontSize: 11, color: textMuted),
                        ),
                        if (order['note'] != null && order['note'].toString().isNotEmpty)
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
                    width: 155,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.receipt_outlined, size: 18, color: textDark),
                          tooltip: 'Print Kitchen Slip',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => AdminModals.showPrintSlipDialog(context, order),
                        ),
                        const SizedBox(width: 4),
                        _buildPrimaryStepButton(context, order),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = orders[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: wellBg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Info: ID & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              // Customer and Payment Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${order['customer'] ?? 'Online Guest'} • ${order['contact'] ?? ''}',
                      style: const TextStyle(fontSize: 11.5, color: textMuted, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentBadge(order['payment'] ?? 'Cash on Delivery'),
                ],
              ),
              const Divider(color: borderLight, height: 16),
              // Items Details
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
              // Responsive Actions & Status Wrap
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
                        icon: const Icon(Icons.receipt_outlined, size: 18, color: textDark),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => AdminModals.showPrintSlipDialog(context, order),
                      ),
                      const SizedBox(width: 4),
                      _buildPrimaryStepButton(context, order),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Color-coded payment method badge (GCash, QRPh, COD only)
  Widget _buildPaymentBadge(String payment) {
    final cleanPay = payment.trim();
    Color bg = const Color(0xFFECEFF1);
    Color fg = const Color(0xFF455A64);

    if (cleanPay.contains('GCash')) {
      bg = const Color(0xFFE8F0FE);
      fg = const Color(0xFF1967D2);
    } else if (cleanPay.contains('QRPh') || cleanPay.contains('MariBank') || cleanPay.contains('SeaBank')) {
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
    final String status = order['status'] ?? '';
    final bool isCustom = order['isCustom'] == true;
    final bool isRider = currentRole == 'Order Dispatcher';

    // RIDER / DISPATCHER ACTIONS
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
              onUpdateStatus(order['id'], 'delivering', '🛵 Out for Delivery'),
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
            () => onUpdateStatus(
              order['id'],
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

    // BAKERY ADMIN / SUPER ADMIN ACTIONS
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
              onUpdateStatus(
                order['id'],
                'pending_spec_review',
                '🎂 Needs Spec Review',
              );
            } else {
              onUpdateStatus(order['id'], 'ready_to_bake', '✓ Ready for Oven');
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
              onUpdateStatus(
                order['id'],
                'pending_spec_review',
                '🎂 Needs Spec Review',
              );
            } else {
              onUpdateStatus(order['id'], 'ready_to_bake', '✓ Ready for Oven');
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
          () => onUpdateStatus(order['id'], 'baking', '🍪 Baking & Packing'),
          () => onUpdateStatus(order['id'], 'spec_rejected', '❌ Spec Rejected'),
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

    if (status == 'ready_to_bake') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkEspresso,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(105, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () =>
            onUpdateStatus(order['id'], 'baking', '🍪 Baking & Packing'),
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
        onPressed: () =>
            onUpdateStatus(order['id'], 'delivering', '🛵 Out for Delivery'),
        child: const Text(
          'Mark Ready',
          style: TextStyle(
            color: Colors.white,
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
        () => onUpdateStatus(order['id'], 'delivered', '✓ Completed Delivery'),
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
    } else if (status.contains('pending')) {
      bg = const Color(0xFFFEF6E9);
      fg = const Color(0xFFC27803);
    } else if (status == 'delivering') {
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
    final completedOrders = orders.where((o) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      final label = (o['statusLabel'] ?? '').toString().toLowerCase();
      return status == 'delivered' ||
          status == 'completed' ||
          status.contains('completed') ||
          label.contains('completed');
    }).toList();

    final double todaySales = completedOrders.fold(0.0, (sum, o) {
      return sum +
          _parseOrderAmount(o['total'] ?? o['totalAmount'] ?? o['subtotal']);
    });

    final customCakeOrders = orders.where((o) {
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
        // Breakpoints: 4 cards on desktop, 2-column grid on mobile/tablet
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
              '${orders.length} Batches',
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
}