import 'package:flutter/material.dart';

class CustomCakeDeskTab extends StatefulWidget {
  final List<Map<String, dynamic>> customCakes;
  final Function(String id, String newStatus, String newLabel) onUpdateStatus;
  final Function(String id) onRejectSpec;

  const CustomCakeDeskTab({
    super.key,
    required this.customCakes,
    required this.onUpdateStatus,
    required this.onRejectSpec,
  });

  @override
  State<CustomCakeDeskTab> createState() => _CustomCakeDeskTabState();
}

class _CustomCakeDeskTabState extends State<CustomCakeDeskTab> {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);
  static const Color wellBg = Color(0xFFF4EDE6);

  int _selectedSubTab = 0; // 0 = Pending Specs, 1 = Cake History

  double _parseTotal(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) {
      final cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final pendingSpecs = widget.customCakes.where((c) {
      final s = (c['status'] ?? '').toString().toLowerCase();
      return s == 'pending_spec_review' ||
          s == 'pending_ewallet' ||
          s == 'pending_cod' ||
          s == 'received';
    }).toList();

    final cakeHistory = widget.customCakes.where((c) {
      final s = (c['status'] ?? '').toString().toLowerCase();
      return s == 'baking' ||
          s == 'delivering' ||
          s == 'delivered' ||
          s == 'completed' ||
          s.contains('completed') ||
          s == 'rejected';
    }).toList();

    final currentList = _selectedSubTab == 0 ? pendingSpecs : cakeHistory;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Tab Header
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom Cake Spec Desk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Review tier structures, piping text, and order logs',
                        style: TextStyle(fontSize: 11.5, color: textMuted),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: wellBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderLight),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _subTabButton('Pending (${pendingSpecs.length})', 0)),
                            const SizedBox(width: 4),
                            Expanded(child: _subTabButton('History (${cakeHistory.length})', 1)),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Cake Spec Inspection Desk',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Review tier structures, piping text, and full historical log of custom creations',
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: wellBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderLight),
                        ),
                        child: Row(
                          children: [
                            _subTabButton('Pending Specs (${pendingSpecs.length})', 0),
                            const SizedBox(width: 4),
                            _subTabButton('Cake Order History (${cakeHistory.length})', 1),
                          ],
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 18),

            if (currentList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderLight),
                ),
                child: Text(
                  _selectedSubTab == 0
                      ? 'No pending custom cake requests awaiting review.'
                      : 'No custom cake order history found.',
                  style: const TextStyle(color: textMuted, fontSize: 13),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentList.length,
                itemBuilder: (context, i) {
                  final cake = currentList[i];

                  final String orderId =
                      cake['id']?.toString() ?? cake['docId']?.toString() ?? '';
                  final String customer =
                      cake['customer']?.toString() ?? 'Online Guest';
                  final String phone = cake['contact']?.toString() ?? cake['phone']?.toString() ?? '';
                  final String paymentMethod =
                      cake['payment']?.toString() ??
                      cake['paymentMethod']?.toString() ??
                      'Cash on Delivery';

                  final String itemTitle =
                      cake['item']?.toString() ??
                      cake['productName']?.toString() ??
                      '1x Custom Celebration Cake';

                  final String tier = cake['tier']?.toString() ?? '1 Tier (6-inch)';
                  final String frosting =
                      cake['frosting']?.toString() ?? 'Buttercream Special';
                  final List<dynamic> toppings = (cake['toppings'] is Iterable)
                      ? (cake['toppings'] as Iterable).toList()
                      : [];

                  double totalAmount = _parseTotal(cake['total']);
                  if (totalAmount == 0.0) {
                    totalAmount = _parseTotal(cake['totalAmount']);
                  }
                  if (totalAmount == 0.0) {
                    totalAmount = _parseTotal(cake['subtotal']);
                  }

                  final String pipingText =
                      cake['dedication']?.toString() ??
                      cake['pipingText']?.toString() ??
                      cake['piping']?.toString() ??
                      cake['cakeMessage']?.toString() ??
                      (cake['note'] != null &&
                              !cake['note'].toString().contains('Delivery')
                          ? cake['note'].toString()
                          : 'No custom dedication requested');

                  final String status = (cake['status'] ?? '').toString();
                  final String statusLabel =
                      (cake['statusLabel'] ?? 'Completed Delivery').toString();
                  final bool isPending = _selectedSubTab == 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header Row (Responsive Wrap)
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  orderId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: darkEspresso,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    paymentMethod,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (totalAmount > 0) ...[
                                  Text(
                                    '₱${totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: brandCocoa,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                _buildStatusPill(statusLabel, status),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$customer ${phone.isNotEmpty ? '• $phone' : ''}',
                          style: const TextStyle(fontSize: 11.5, color: textMuted, fontWeight: FontWeight.w500),
                        ),
                        const Divider(color: borderLight, height: 18),

                        // Item Title
                        Text(
                          itemTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Spec Tags Wrap
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildChipTag('Tier: $tier'),
                            _buildChipTag('Frosting: $frosting'),
                            for (var t in toppings) _buildChipTag('Topping: $t'),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Piping Inscription Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: wellBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🎂', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Piping Inscription: "$pipingText"',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                    color: textDark,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Actions for Pending Items
                        if (isPending) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: textMuted),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => widget.onRejectSpec(orderId),
                                child: const Text(
                                  'Reject Spec',
                                  style: TextStyle(color: textMuted, fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandCocoa,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => widget.onUpdateStatus(
                                  orderId,
                                  'baking',
                                  '🍪 Baking & Packing',
                                ),
                                icon: const Icon(Icons.check, size: 15, color: Colors.white),
                                label: const Text(
                                  'Approve & Bake',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _subTabButton(String label, int index) {
    final bool isSelected = _selectedSubTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedSubTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? brandCocoa : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildChipTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEBE4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: brandCocoa,
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, String status) {
    Color bg = wellBg;
    Color fg = textDark;
    final s = status.toLowerCase();

    if (s == 'baking') {
      bg = const Color(0xFFFBEBE4);
      fg = brandCocoa;
    } else if (s.contains('pending') || s == 'received') {
      bg = const Color(0xFFFEF6E9);
      fg = const Color(0xFFC27803);
    } else if (s == 'delivering') {
      bg = const Color(0xFFE8F0FE);
      fg = const Color(0xFF1967D2);
    } else if (s == 'delivered' || s.contains('completed')) {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10.5),
      ),
    );
  }
}