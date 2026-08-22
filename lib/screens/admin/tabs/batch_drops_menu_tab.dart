import 'package:flutter/material.dart';
import '../admin_modals.dart';

class BatchDropsMenuTab extends StatefulWidget {
  final List<Map<String, dynamic>> inventory;
  final String currentRole; // 'Super Admin' or 'Baker Admin'
  final Function(Map<String, dynamic>) onAddProduct;
  final Function(int index) onToggleStatus;
  final Function(int index, int delta) onAdjustStock;

  const BatchDropsMenuTab({
    super.key,
    required this.inventory,
    required this.currentRole,
    required this.onAddProduct,
    required this.onToggleStatus,
    required this.onAdjustStock,
  });

  @override
  State<BatchDropsMenuTab> createState() => _BatchDropsMenuTabState();
}

class _BatchDropsMenuTabState extends State<BatchDropsMenuTab> {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF7A6559);
  static const Color borderLight = Color(0xFFEFE4D6);
  static const Color creamCard = Color(0xFFFDFBF7);
  static const Color warmBlush = Color(0xFFFBEBE4);

  String _activeCategory = 'All';

  List<Map<String, dynamic>> get _filteredInventory {
    if (_activeCategory == 'All') return widget.inventory;
    return widget.inventory.where((item) {
      final cat = (item['category'] ?? '').toString().toLowerCase();
      return cat == _activeCategory.toLowerCase() ||
          cat.contains(_activeCategory.toLowerCase().replaceAll('s', ''));
    }).toList();
  }

  double _parsePrice(dynamic priceVal) {
    if (priceVal is num) return priceVal.toDouble();
    if (priceVal is String) {
      final cleaned = priceVal.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuperAdmin = widget.currentRole == 'Super Admin';
    final int activeCount =
        widget.inventory.where((item) => item['active'] == true).length;
    final int totalStock = widget.inventory.fold(
      0,
      (sum, item) => sum + ((item['stock'] as num?)?.toInt() ?? 0),
    );
    final int lowStockCount = widget.inventory
        .where((item) => ((item['stock'] as num?)?.toInt() ?? 0) <= 5)
        .length;

    final categories = [
      {'label': 'All Treats', 'value': 'All', 'icon': '✨'},
      {'label': 'Cookies', 'value': 'Cookies', 'icon': '🍪'},
      {'label': 'Brownies', 'value': 'Brownies', 'icon': '🍫'},
      {'label': 'Cakes', 'value': 'Cakes', 'icon': '🎂'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isDesktop = width >= 850;
        final bool isMobile = width < 600;

        // Metric Card Breakpoint: 4 columns on desktop, 2 columns on mobile/tablet
        final double cardWidth = isDesktop
            ? (width - (3 * 12)) / 4
            : (width >= 380 ? (width - 12) / 2 : width);

        // Product Cards Grid Breakpoint
        final int columns = width < 680 ? 1 : (width < 1120 ? 2 : 3);
        const double spacing = 14.0;
        final double productCardWidth = (width - (columns - 1) * spacing) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDF4E9), Color(0xFFF7E7D5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: darkEspresso.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: borderLight, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: const Text('🧁', style: TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Oven Drops Desk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.5,
                                      color: textDark,
                                    ),
                                  ),
                                  Text(
                                    'Bake inventory & stock manager',
                                    style: TextStyle(fontSize: 11, color: textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSuperAdmin) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandCocoa,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => AdminModals.showAddProductDialog(context, widget.onAddProduct),
                              icon: const Icon(Icons.cookie_outlined, size: 16, color: Colors.white),
                              label: const Text('+ Bake New SKU Drop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: borderLight, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: const Text('🧁', style: TextStyle(fontSize: 26)),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'Daily Oven Drops & Sweet Batch Desk',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17,
                                        color: textDark,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('✨', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isSuperAdmin
                                      ? 'Bake inventory manager • Full SKU recipes, pricing & active drops.'
                                      : 'Baker station: Real-time stock counters and freshly baked drop controls.',
                                  style: const TextStyle(fontSize: 11.5, color: textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isSuperAdmin)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandCocoa,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => AdminModals.showAddProductDialog(context, widget.onAddProduct),
                            icon: const Icon(Icons.cookie_outlined, size: 16, color: Colors.white),
                            label: const Text(
                              '+ Bake New SKU Drop',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 18),

            // Responsive Metrics Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _cuteMetricCard('🍪 Live Sweets', '$activeCount Active', 'Available on storefront', brandCocoa, cardWidth),
                _cuteMetricCard('🧺 In Tray Counter', '$totalStock Pieces', 'Fresh batches ready', const Color(0xFF2E7D32), cardWidth),
                _cuteMetricCard('⚠️ Oven Alert', '$lowStockCount Items', '5 or fewer units left', const Color(0xFFC27803), cardWidth),
                _cuteMetricCard('⏱️ Next Batch Drop', '18 mins', 'Preheating deck ovens', darkEspresso, cardWidth),
              ],
            ),
            const SizedBox(height: 20),

            // Category Filter Pills & Counter Badge
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final bool isSelected = _activeCategory == cat['value'];
                    return InkWell(
                      onTap: () => setState(() => _activeCategory = cat['value']!),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? darkEspresso : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? darkEspresso : borderLight, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat['icon']!, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 5),
                            Text(
                              cat['label']!,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Showing ${_filteredInventory.length} Items',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: brandCocoa),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Product Cards Grid
            if (_filteredInventory.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderLight),
                ),
                alignment: Alignment.center,
                child: const Text('No drop items found in this category.', style: TextStyle(color: textMuted, fontSize: 13)),
              )
            else
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _filteredInventory.map((item) {
                  final originalIndex = widget.inventory.indexOf(item);
                  final bool active = item['active'] == true;
                  final int stock = (item['stock'] as num?)?.toInt() ?? 0;
                  final double capacityRatio = (stock / 35.0).clamp(0.0, 1.0);
                  final double price = _parsePrice(item['price']);
                  final String category = (item['category'] ?? 'TREAT').toString().toUpperCase();
                  final String portionSize = item['size']?.toString() ??
                      (category.contains('COOKIE')
                          ? '140g Palm-Sized Piece'
                          : category.contains('BROWNIE')
                              ? 'Fudge Slice (Half Pan)'
                              : '6" Artisan Cake');

                  final String itemIcon = item['icon'] ??
                      (category.contains('COOKIE')
                          ? '🍪'
                          : category.contains('BROWNIE')
                              ? '🍫'
                              : '🎂');

                  return Container(
                    width: productCardWidth,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? const Color(0xFFEFE2D3) : const Color(0xFFE8E0D7),
                        width: 1.4,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: active ? warmBlush : const Color(0xFFEFEBE6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(itemIcon, style: const TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF2E9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: brandCocoa,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '₱${price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: darkEspresso,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item['name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: active ? textDark : textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    portionSize,
                                    style: const TextStyle(fontSize: 10.5, color: textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: active,
                              activeColor: brandCocoa,
                              activeTrackColor: const Color(0xFFE8C8B5),
                              onChanged: (val) => widget.onToggleStatus(originalIndex),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Capacity Meter
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: creamCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderLight),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    stock == 0 ? 'Sold Out' : '$stock in tray',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: stock == 0
                                          ? const Color(0xFFD32F2F)
                                          : (stock <= 5 ? const Color(0xFFE65100) : const Color(0xFF2E7D32)),
                                    ),
                                  ),
                                  Text(
                                    '${(capacityRatio * 100).toInt()}% Capacity',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: capacityRatio,
                                  minHeight: 5,
                                  backgroundColor: const Color(0xFFEFE4D6),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    stock == 0 ? const Color(0xFFE57373) : brandCocoa,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Quick Stock Counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tray Count:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textMuted),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF4EE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderLight),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: stock > 0 ? () => widget.onAdjustStock(originalIndex, -1) : null,
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.remove,
                                        size: 15,
                                        color: stock > 0 ? textDark : const Color(0xFFC4B8B0),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 28),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$stock',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: stock == 0 ? const Color(0xFFD32F2F) : textDark,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => widget.onAdjustStock(originalIndex, 1),
                                    borderRadius: BorderRadius.circular(6),
                                    child: const Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(Icons.add, size: 15, color: brandCocoa),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _cuteMetricCard(
    String tag,
    String value,
    String sub,
    Color tagColor,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: tagColor,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}