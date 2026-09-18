import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../../../utils/pdf_report_generator.dart';

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

  Future<void> _exportPdf(
    double realizedRevenue,
    List<Map<String, dynamic>> completedOrders,
    int customCakesCount,
    List<Map<String, dynamic>> bakingOrders,
  ) async {
    final stats = {
      'totalSales': realizedRevenue.toStringAsFixed(2),
      'totalOrders': widget.orders.length.toString(),
      'pendingOrders': (widget.orders.length - completedOrders.length).toString(),
      'completedOrders': completedOrders.length.toString(),
      'customCakesCount': customCakesCount.toString(),
      'bakingOrders': bakingOrders.length.toString(),
    };
    final bytes = await PdfReportGenerator.generateDashboardReport(stats, widget.orders);
    await Printing.sharePdf(bytes: bytes, filename: 'dashboard_report.pdf');
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
            isMobile
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => _exportPdf(realizedRevenue, completedOrders, customCakesCount, bakingOrders),
              icon: const Icon(Icons.download_rounded, color: brandCocoa),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFBF7F2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: borderLight)),
              ),
            ),
          ),
        ],
      )
    : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Dashboard Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
          ElevatedButton.icon(
            onPressed: () => _exportPdf(realizedRevenue, completedOrders, customCakesCount, bakingOrders),
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
            const SizedBox(height: 16),
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

            // Section 1.5: Revenue Trend Chart
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
                  Row(
                    children: [
                      const Text('📈', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      const Text(
                        'Revenue Trend',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EDE6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Last ${widget.orders.length} Orders',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8C4A27),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cumulative revenue from completed deliveries over time',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF6E5D53)),
                  ),
                  const SizedBox(height: 20),
                  Builder(builder: (context) {
                    // Build cumulative revenue spots from completed orders
                    final completed = widget.orders.where((o) {
                      final s = (o['status'] ?? '').toString().toLowerCase();
                      return s == 'delivered' || s == 'completed' || s.contains('completed');
                    }).toList();

                    if (completed.isEmpty) {
                      return Container(
                        height: 160,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EDE6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No completed orders yet — revenue will appear here once deliveries are done.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF6E5D53)),
                        ),
                      );
                    }

                    // Build line spots: each order is a point, x = index, y = cumulative revenue
                    double cumulative = 0.0;
                    final spots = completed.asMap().entries.map((e) {
                      final val = e.value['total'] ?? e.value['totalAmount'] ?? e.value['subtotal'];
                      double amt = 0.0;
                      if (val is num) amt = val.toDouble();
                      if (val is String) amt = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                      cumulative += amt;
                      return FlSpot(e.key.toDouble(), cumulative);
                    }).toList();

                    final maxY = cumulative > 0 ? (cumulative * 1.2).ceilToDouble() : 1000.0;

                    return SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (spots.length - 1).toDouble().clamp(1, double.infinity),
                          minY: 0,
                          maxY: maxY,
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (spots) => spots.map((s) {
                                return LineTooltipItem(
                                  '₱${s.y.toStringAsFixed(2)}',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                );
                              }).toList(),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY / 4,
                            getDrawingHorizontalLine: (_) => const FlLine(
                              color: Color(0xFFEFE3D5),
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: maxY / 4,
                                getTitlesWidget: (v, _) => Text(
                                  '₱${v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (v, _) {
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= completed.length) return const SizedBox.shrink();
                                  // show every nth label to avoid crowding
                                  final step = (completed.length / 4).ceil().clamp(1, 999);
                                  if (idx % step != 0 && idx != completed.length - 1) return const SizedBox.shrink();
                                  return Text('${idx + 1}', style: const TextStyle(fontSize: 9.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600));
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: const Color(0xFF8C4A27),
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: spots.length <= 10,
                                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: const Color(0xFF8C4A27),
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF8C4A27).withOpacity(0.18),
                                    const Color(0xFF8C4A27).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B7355).withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF2E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('🔥', style: TextStyle(fontSize: 18)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        o['item']?.toString() ?? 'Artisan Bakery Batch',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: Color(0xFF1F1209),
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Order ${o['id'] ?? o['docId']} • ${o['customer'] ?? 'Guest'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8EE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Baking',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            // Modern Pipeline Node Tracker
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  _PipelineNode(label: 'Prep', isCompleted: true),
                                  _PipelineLine(isCompleted: true),
                                  _PipelineNode(label: 'Baking', isActive: true, isPulsing: true),
                                  _PipelineLine(isCompleted: false),
                                  _PipelineNode(label: 'Cooling', isActive: false),
                                ],
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
                                _inventoryFilterChip('Cake Loafs', icon: '🍞'),
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
                                _inventoryFilterChip('Cake Loafs', icon: '🍞'),
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

                      // For Bar Chart, we take top 6 products to avoid clutter
                      final displayProducts = filteredProducts.take(6).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Bar Chart
                          if (displayProducts.isNotEmpty)
                            Container(
                              height: 220,
                              padding: const EdgeInsets.only(top: 10, right: 20),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 50,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipPadding: const EdgeInsets.all(8),
                                      tooltipMargin: 8,
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${rod.toY.toInt()} in stock',
                                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= displayProducts.length) return const SizedBox.shrink();
                                          final name = displayProducts[value.toInt()]['name']?.toString() ?? '';
                                          final shortName = name.length > 8 ? '${name.substring(0, 8)}..' : name;
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: Text(shortName, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w700)),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 36,
                                        interval: 10,
                                        getTitlesWidget: (value, meta) {
                                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold));
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 10,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: const Color(0xFFE5E7EB),
                                      strokeWidth: 1,
                                      dashArray: [4, 4],
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: displayProducts.asMap().entries.map((entry) {
                                    final stock = int.tryParse(entry.value['stock']?.toString() ?? '24') ?? 24;
                                    final bool isLowStock = stock <= 5;
                                    return BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stock.toDouble(),
                                          color: isLowStock ? const Color(0xFFB45309) : const Color(0xFF8B7355),
                                          width: 22,
                                          borderRadius: BorderRadius.circular(4),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: 50,
                                            color: const Color(0xFFF3F4F6),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 30),
                          const Row(
                            children: [
                              Icon(Icons.warning_rounded, color: Color(0xFFB45309), size: 18),
                              SizedBox(width: 8),
                              Text('Low Stock Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Low Stock List
                          ...filteredProducts.where((p) => (int.tryParse(p['stock']?.toString() ?? '24') ?? 24) <= 5).map((p) {
                            final name = p['name']?.toString() ?? 'Bakery Item';
                            final stock = int.tryParse(p['stock']?.toString() ?? '24') ?? 24;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8EE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFEDD5A0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB45309).withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1F1209))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB45309),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text('$stock units left', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (filteredProducts.where((p) => (int.tryParse(p['stock']?.toString() ?? '24') ?? 24) <= 5).isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              alignment: Alignment.center,
                              child: const Text('All items are well-stocked! 🎉', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                        ],
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

class _PipelineNode extends StatefulWidget {
  final String label;
  final bool isCompleted;
  final bool isActive;
  final bool isPulsing;

  const _PipelineNode({
    required this.label,
    this.isCompleted = false,
    this.isActive = false,
    this.isPulsing = false,
  });

  @override
  State<_PipelineNode> createState() => _PipelineNodeState();
}

class _PipelineNodeState extends State<_PipelineNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCompleted || widget.isActive
        ? const Color(0xFF8C4A27) // brandCocoa
        : const Color(0xFFD1D5DB); // grey-300

    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double scale = widget.isPulsing ? 1.0 + (_controller.value * 0.2) : 1.0;
            final double opacity = widget.isPulsing ? 1.0 - (_controller.value * 0.5) : 1.0;
            
            return Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isPulsing)
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(opacity * 0.4),
                      ),
                    ),
                  ),
                // This transparent container ensures the stack is always at least 14x14
                // preventing layout shifts when pulsing starts/stops.
                Container(width: 14, height: 14, color: Colors.transparent),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isCompleted ? color : Colors.white,
                    border: Border.all(
                      color: color,
                      width: 2.5,
                    ),
                  ),
                  child: widget.isCompleted 
                      ? const Icon(Icons.check, size: 6, color: Colors.white)
                      : null,
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 6),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w600,
            color: widget.isActive ? const Color(0xFF1F1209) : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

class _PipelineLine extends StatelessWidget {
  final bool isCompleted;

  const _PipelineLine({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(top: 6, left: 4, right: 4), // align with center of 14x14 circle
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF8C4A27) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}