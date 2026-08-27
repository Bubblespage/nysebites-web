import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../../../utils/pdf_report_generator.dart';
import 'dart:convert';
import '../admin_modals.dart';

class CustomCakeDeskTab extends StatefulWidget {
  final List<Map<String, dynamic>> customCakes;
  final Function(String id, String newStatus, String newLabel, [Map<String, dynamic>? extraData]) onUpdateStatus;
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
  static const Color brandCocoa = Color(0xFF3E2723);
  static const Color darkEspresso = Color(0xFF1F1209);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color wellBg = Color(0xFFF3F4F6);

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
          s == 'rejected' ||
          s == 'spec_rejected' ||
          s == 'quote_received' ||
          s == 'ready_to_bake';
    }).toList();

    final currentList = _selectedSubTab == 0 ? pendingSpecs : cakeHistory;

    currentList.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1; // nulls at the bottom
      if (bDate == null) return -1;
      
      if (aDate is Timestamp && bDate is Timestamp) {
        return bDate.compareTo(aDate); // latest at top
      }
      return 0;
    });

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
                      Row(
                        children: [
                          Expanded(
                            child: Container(
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
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              final filterText = _selectedSubTab == 0 ? 'Pending Specs' : 'Cake Order History';
                              final bytes = await PdfReportGenerator.generateCustomCakesReport(
                                currentList,
                                filterInfo: filterText,
                              );
                              final filename = 'custom_cakes_${filterText.toLowerCase().replaceAll(' ', '_')}.pdf';
                              await Printing.sharePdf(bytes: bytes, filename: filename);
                            },
                            icon: const Icon(Icons.download_rounded, color: brandCocoa),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFFBF7F2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: borderLight)),
                            ),
                          ),
                        ],
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
                      Row(
                        children: [
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
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final filterText = _selectedSubTab == 0 ? 'Pending Specs' : 'Cake Order History';
                              final bytes = await PdfReportGenerator.generateCustomCakesReport(
                                currentList,
                                filterInfo: filterText,
                              );
                              final filename = 'custom_cakes_${filterText.toLowerCase().replaceAll(' ', '_')}.pdf';
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
              Builder(
                builder: (context) {
                  final flattenedList = <Map<String, dynamic>>[];
                  for (final order in currentList) {
                    if (order['customCakes'] != null && (order['customCakes'] as List).isNotEmpty) {
                      final cakes = order['customCakes'] as List;
                      for (int i = 0; i < cakes.length; i++) {
                        final clonedOrder = Map<String, dynamic>.from(order);
                        clonedOrder['customCakes'] = [cakes[i]];
                        flattenedList.add({
                          'order': clonedOrder,
                          'customCake': cakes[i],
                        });
                      }
                    } else {
                      flattenedList.add({
                        'order': order,
                        'customCake': null,
                      });
                    }
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: flattenedList.length,
                    itemBuilder: (context, i) {
                      final entry = flattenedList[i];
                      final cake = entry['order'];
                      final customCake = entry['customCake'];

                      final String orderId = cake['id']?.toString() ?? cake['docId']?.toString() ?? '';
                      final String customer = cake['customer']?.toString() ?? 'Online Guest';
                      final String phone = cake['contact']?.toString() ?? cake['phone']?.toString() ?? '';
                      final String paymentMethod = cake['payment']?.toString() ?? cake['paymentMethod']?.toString() ?? 'Cash on Delivery';

                      String itemTitle = cake['item']?.toString() ?? cake['productName']?.toString() ?? '1x Custom Celebration Cake';
                      String tier = cake['tier']?.toString() ?? '1 Tier (6-inch)';
                      String frosting = cake['frosting']?.toString() ?? 'Buttercream Special';
                      
                      final List<dynamic> toppings = (cake['toppings'] is Iterable) ? (cake['toppings'] as Iterable).toList() : [];

                      double totalAmount = _parseTotal(cake['total']);
                      if (totalAmount == 0.0) totalAmount = _parseTotal(cake['totalAmount']);
                      if (totalAmount == 0.0) totalAmount = _parseTotal(cake['subtotal']);

                      String pipingText = cake['dedication']?.toString() ??
                          cake['pipingText']?.toString() ??
                          cake['piping']?.toString() ??
                          cake['cakeMessage']?.toString() ??
                          (cake['note'] != null && !cake['note'].toString().contains('Delivery')
                              ? cake['note'].toString()
                              : 'No custom dedication requested');

                      String? refImageBase64 = cake['referenceImageBase64']?.toString();

                      if (customCake != null) {
                        final ccQuantity = customCake['quantity'] ?? 1;
                        final ccName = customCake['name']?.toString() ?? 'Custom Cake';
                        itemTitle = '${ccQuantity}x $ccName';
                        
                        final ccDesc = customCake['description']?.toString() ?? '';
                        final parts = ccDesc.split(' • ');
                        tier = '1 Tier (6-inch)';
                        frosting = 'Buttercream Special';
                        pipingText = 'No custom dedication requested';
                        for (final part in parts) {
                          if (part.startsWith('Dimensions:')) tier = part.replaceFirst('Dimensions:', '').trim();
                          else if (part.startsWith('Icing:')) frosting = part.replaceFirst('Icing:', '').trim();
                          else if (part.startsWith('Piping:')) pipingText = part.replaceFirst('Piping:', '').trim().replaceAll('"', '');
                        }
                        refImageBase64 = customCake['referenceImageBase64']?.toString();
                      }

                      final String status = (cake['status'] ?? '').toString();
                      final String statusLabel = (cake['statusLabel'] ?? 'Completed Delivery').toString();
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

                        Text(
                          itemTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildChipTag('Tier: $tier'),
                            _buildChipTag('Frosting: $frosting'),
                            if (customCake == null)
                              for (var t in toppings) _buildChipTag('Topping: $t'),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: wellBg, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🎂', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Piping Inscription: "$pipingText"',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: textDark, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (refImageBase64 != null && refImageBase64.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: wellBg, borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🖼️', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Customer Reference Image',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: textDark),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              insetPadding: const EdgeInsets.all(16),
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.memory(base64Decode(refImageBase64!), fit: BoxFit.contain),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                                    onPressed: () => Navigator.pop(ctx),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(base64Decode(refImageBase64), width: 140, height: 140, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

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
                                onPressed: () => AdminModals.showCustomCakeInspectionDrawer(
                                  context,
                                  cake,
                                  (basePrice, addonPrice) {
                                    final double total = basePrice + addonPrice;
                                    final double downPayment = total / 2;
                                    final double balance = total - downPayment;
                                    
                                    widget.onUpdateStatus(
                                      orderId, 
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
                                  () => widget.onRejectSpec(orderId),
                                ),
                                icon: const Icon(Icons.cake_outlined, size: 15, color: Colors.white),
                                label: const Text(
                                  'Inspect Spec',
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
class StaggeredSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  const StaggeredSlideIn({super.key, required this.child, required this.index});
  @override
  State<StaggeredSlideIn> createState() => _StaggeredSlideInState();
}

class _StaggeredSlideInState extends State<StaggeredSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _offsetAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _offsetAnim,
        child: widget.child,
      ),
    );
  }
}

class HoverElevate extends StatefulWidget {
  final Widget child;
  const HoverElevate({super.key, required this.child});
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
        transform: Matrix4.translationValues(0, _isHovering ? -4 : 0, 0),
        decoration: BoxDecoration(
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B7355).withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}
