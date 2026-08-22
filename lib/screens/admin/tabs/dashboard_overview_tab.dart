import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardOverviewTab extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

  const DashboardOverviewTab({super.key, required this.orders});

  @override
  State<DashboardOverviewTab> createState() => _DashboardOverviewTabState();
}

class _DashboardOverviewTabState extends State<DashboardOverviewTab> {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);
  static const Color wellBg = Color(0xFFF4EDE6);

  String _inventoryCategoryFilter = 'All';

  final List<Map<String, dynamic>> _defaultProducts = [
    {
      'name': 'Snicker-Doodle Hug',
      'category': 'COOKIES',
      'price': 240.0,
      'stock': 24,
      'icon': '🥜',
    },
    {
      'name': 'Dark Chocolate Noir',
      'category': 'COOKIES',
      'price': 220.0,
      'stock': 24,
      'icon': '🍫',
    },
    {
      'name': 'Belgian Choco Chip',
      'category': 'COOKIES',
      'price': 200.0,
      'stock': 18,
      'icon': '🍪',
    },
    {
      'name': "Hershey's Almond Cloud Squares",
      'category': 'BROWNIES',
      'price': 380.0,
      'stock': 12,
      'icon': '☁️',
    },
    {
      'name': 'Lavender Noir Velvet',
      'category': 'CAKES',
      'price': 950.0,
      'stock': 5,
      'icon': '🎂',
    },
  ];

  double _parseAmount(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) {
      final cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Completed Deliveries & Realized Revenue
    final completedOrders = widget.orders.where((o) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      final label = (o['statusLabel'] ?? '').toString().toLowerCase();
      return status == 'delivered' ||
          status == 'completed' ||
          status.contains('completed') ||
          label.contains('completed');
    }).toList();

    final double realizedRevenue = completedOrders.fold(
      0.0,
      (sum, o) =>
          sum + _parseAmount(o['total'] ?? o['totalAmount'] ?? o['subtotal']),
    );

    // 2. Custom Cake Count
    final int customCakesCount = widget.orders.where((o) {
      final bool isCustom =
          o['isCustom'] == true ||
          (o['item'] ?? '').toString().toLowerCase().contains('custom') ||
          (o['category'] ?? '').toString().toLowerCase().contains('cake');
      return isCustom;
    }).length;

    // 3. Batches Currently Baking
    final bakingOrders = widget.orders.where((o) {
      final status = (o['status'] ?? '').toString().toLowerCase();
      return status == 'baking' ||
          status.contains('bake') ||
          status == 'ready_to_bake';
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isDesktop = screenWidth >= 850;
        final bool isMobile = screenWidth < 550;

        // Metric Card Width Calculation (4 columns on Desktop, 2 columns on Mobile/Tablet)
        final double cardWidth = isDesktop
            ? (screenWidth - (3 * 12)) / 4
            : (screenWidth >= 380 ? (screenWidth - 12) / 2 : screenWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Responsive Metrics Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metricCard(
                  'TOTAL REVENUE',
                  '₱${realizedRevenue.toStringAsFixed(2)}',
                  'From completed deliveries',
                  brandCocoa,
                  cardWidth,
                ),
                _metricCard(
                  'ACTIVE ORDERS',
                  '${widget.orders.length} Orders',
                  '$customCakesCount custom cakes',
                  const Color(0xFFC27803),
                  cardWidth,
                ),
                _metricCard(
                  'BAKING IN OVEN',
                  '${bakingOrders.length} Batches',
                  'Current deck load',
                  darkEspresso,
                  cardWidth,
                ),
                _metricCard(
                  'DELIVERIES DONE',
                  '${completedOrders.length} Orders',
                  'Completed drops',
                  const Color(0xFF2E7D32),
                  cardWidth,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 2: Baking in Oven Deck Monitor
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text('🔥', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 8),
                                Text(
                                  'Baking in Oven Deck',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15.5,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFAF2E9),
                                    foregroundColor: brandCocoa,
                                    elevation: 0,
                                    side: const BorderSide(color: Color(0xFFE8DACB)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: darkEspresso,
                                        content: Text('Kitchen prep tray pipeline synchronized.'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 14),
                                  label: const Text(
                                    'Start Kitchen Batch',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F0FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${bakingOrders.length} Active Trays',
                                    style: const TextStyle(
                                      color: Color(0xFF1967D2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('🔥', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 8),
                                Text(
                                  'Baking in Oven Deck',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFAF2E9),
                                    foregroundColor: brandCocoa,
                                    elevation: 0,
                                    side: const BorderSide(color: Color(0xFFE8DACB)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: darkEspresso,
                                        content: Text('Kitchen prep tray pipeline synchronized.'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text(
                                    'Start Kitchen Batch',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F0FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${bakingOrders.length} Active Trays',
                                    style: const TextStyle(
                                      color: Color(0xFF1967D2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  const SizedBox(height: 4),
                  const Text(
                    'Live monitor of customer orders & kitchen prep trays currently inside the oven',
                    style: TextStyle(fontSize: 11.5, color: textMuted),
                  ),
                  const SizedBox(height: 14),

                  if (bakingOrders.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: wellBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEFE4D6)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'No batches in the oven right now. Click "Start Kitchen Batch" or approve pending orders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: textMuted),
                      ),
                    )
                  else
                    ...bakingOrders.map((o) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: wellBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('⏲️', style: TextStyle(fontSize: 15)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o['item']?.toString() ?? 'Artisan Bakery Batch',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Order ${o['id'] ?? o['docId']} • ${o['customer'] ?? 'Guest'}',
                                    style: const TextStyle(fontSize: 11, color: textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Baking',
                                style: TextStyle(
                                  color: Color(0xFFE65100),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Live Inventory Stock Monitor
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Live Inventory Stock Monitor',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Real-time stock counts streaming directly for all menu items',
                              style: TextStyle(fontSize: 11.5, color: textMuted),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _inventoryFilterChip('All'),
                                _inventoryFilterChip('Cookies', icon: '🍪'),
                                _inventoryFilterChip('Brownies', icon: '🍫'),
                                _inventoryFilterChip('Cakes', icon: '🎂'),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Live Inventory Stock Monitor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: textDark,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Real-time stock counts streaming directly for all menu items',
                                  style: TextStyle(fontSize: 12, color: textMuted),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _inventoryFilterChip('All'),
                                _inventoryFilterChip('Cookies', icon: '🍪'),
                                _inventoryFilterChip('Brownies', icon: '🍫'),
                                _inventoryFilterChip('Cakes', icon: '🎂'),
                              ],
                            ),
                          ],
                        ),
                  const SizedBox(height: 14),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('products').snapshots(),
                    builder: (context, snapshot) {
                      List<Map<String, dynamic>> products = [];

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        products = snapshot.data!.docs
                            .map((d) => {'docId': d.id, ...d.data()})
                            .toList();
                      } else {
                        products = _defaultProducts;
                      }

                      final filteredProducts = products.where((p) {
                        if (_inventoryCategoryFilter == 'All') return true;
                        final category = (p['category'] ?? '').toString().toLowerCase();
                        return category.contains(_inventoryCategoryFilter.toLowerCase());
                      }).toList();

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, __) => const Divider(color: borderLight, height: 16),
                        itemBuilder: (context, index) {
                          final p = filteredProducts[index];
                          final name = p['name']?.toString() ?? 'Bakery Item';
                          final category = p['category']?.toString().toUpperCase() ?? 'COOKIES';
                          final price = _parseAmount(p['price']);
                          final stock = int.tryParse(p['stock']?.toString() ?? '24') ?? 24;
                          final icon = p['icon']?.toString() ??
                              (category.contains('CAKE') ? '🎂' : '🍪');
                          final bool isLowStock = stock <= 5;

                          return Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: wellBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(icon, style: const TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                        color: textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: textMuted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₱${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isLowStock
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isLowStock ? '$stock left' : '$stock in stock',
                                  style: TextStyle(
                                    color: isLowStock
                                        ? const Color(0xFFE65100)
                                        : const Color(0xFF2E7D32),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _inventoryFilterChip(String label, {String? icon}) {
    final bool active = _inventoryCategoryFilter == label;
    return InkWell(
      onTap: () => setState(() => _inventoryCategoryFilter = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active ? brandCocoa : wellBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? brandCocoa : borderLight),
        ),
        child: Text(
          icon != null ? '$label $icon' : label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : textDark,
          ),
        ),
      ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 10.5, color: textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}