import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../../../utils/pdf_report_generator.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../admin_modals.dart';
import '../../../theme/app_colors.dart';

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
  static const Color brandCocoa = AppColors.darkGarnet;
  static const Color darkEspresso = AppColors.brandRed;
  static const Color textDark = AppColors.brandRed;
  static const Color textMuted = AppColors.brandRed;
  static const Color borderLight = AppColors.brandRed;
  static const Color wellBg = AppColors.brandRed;

  int _selectedSubTab = 0; // 0 = Pending Specs, 1 = In Progress, 2 = History, 3 = Schedule & Slots
  DateTime _currentMonth = DateTime.now();

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

    final inProgress = widget.customCakes.where((c) {
      final s = (c['status'] ?? '').toString().toLowerCase();
      return s == 'quote_received' ||
          s == 'contract_signed' ||
          s == 'pending_retainer_verification' ||
          s == 'ready_to_bake' ||
          s == 'baking' ||
          s == 'baked_payment_required' ||
          s == 'baked_payment_verifying' ||
          s == 'delivering';
    }).toList();

    final cakeHistory = widget.customCakes.where((c) {
      final s = (c['status'] ?? '').toString().toLowerCase();
      return s == 'delivered' ||
          s == 'completed' ||
          s.contains('completed') ||
          s == 'rejected' ||
          s == 'spec_rejected';
    }).toList();

    final currentList = _selectedSubTab == 0
        ? pendingSpecs
        : (_selectedSubTab == 1 ? inProgress : cakeHistory);

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
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _subTabButton('Pending (${pendingSpecs.length})', 0),
                                    const SizedBox(width: 4),
                                    _subTabButton('In Progress (${inProgress.length})', 1),
                                    const SizedBox(width: 4),
                                    _subTabButton('History (${cakeHistory.length})', 2),
                                    const SizedBox(width: 4),
                                    _subTabButton('Schedule', 3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              final filterText = _selectedSubTab == 0 
                                  ? 'Pending Specs' 
                                  : (_selectedSubTab == 1 ? 'In Progress' : 'Cake Order History');
                              final bytes = await PdfReportGenerator.generateCustomCakesReport(
                                currentList,
                                filterInfo: filterText,
                              );
                              final filename = 'custom_cakes_${filterText.toLowerCase().replaceAll(' ', '_')}.pdf';
                              await Printing.sharePdf(bytes: bytes, filename: filename);
                            },
                            icon: const Icon(Icons.download_rounded, color: brandCocoa),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.brandRed,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: borderLight)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: wellBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderLight),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _subTabButton('Pending Specs (${pendingSpecs.length})', 0),
                                    const SizedBox(width: 4),
                                    _subTabButton('In Progress (${inProgress.length})', 1),
                                    const SizedBox(width: 4),
                                    _subTabButton('Cake Order History (${cakeHistory.length})', 2),
                                    const SizedBox(width: 4),
                                    _subTabButton('Schedule & Slots', 3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final filterText = _selectedSubTab == 0 
                                  ? 'Pending Specs' 
                                  : (_selectedSubTab == 1 ? 'In Progress' : 'Cake Order History');
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

            if (_selectedSubTab == 3)
              _buildScheduleAndSlotsView(inProgress, isMobile)
            else if (currentList.isEmpty)
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
                      : (_selectedSubTab == 1 
                          ? 'No custom cakes currently in progress.'
                          : 'No custom cake order history found.'),
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
                      final bool isInProgress = _selectedSubTab == 1;

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
                                    color: AppColors.brandRed,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    paymentMethod,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandRed,
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
                        ] else if (isInProgress) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              _buildActionButtons(context, cake, orderId, status),
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
        color: AppColors.bgPastelPink,
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
    label = label.replaceAll('Packing', 'Preparation');
    Color bg = wellBg;
    Color fg = textDark;
    final s = status.toLowerCase();

    if (s == 'baking') {
      bg = AppColors.bgPastelPink;
      fg = brandCocoa;
    } else if (s.contains('pending') || s == 'received') {
      bg = AppColors.brandRed;
      fg = AppColors.brandRed;
    } else if (s == 'delivering') {
      bg = AppColors.brandRed;
      fg = AppColors.brandRed;
    } else if (s == 'delivered' || s.contains('completed')) {
      bg = AppColors.brandRed;
      fg = AppColors.brandRed;
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

  void _showDispatchDialog(BuildContext context, String targetDocId, Map<String, dynamic> order) {
    final TextEditingController riderNameController = TextEditingController(text: order['riderName']?.toString());
    final TextEditingController trackingLinkController = TextEditingController(text: order['trackingLink']?.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dispatch Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: riderNameController,
              decoration: const InputDecoration(
                labelText: 'Rider Details (Name / Plate No)',
                hintText: 'e.g. Juan Dela Cruz - GrabCar',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: trackingLinkController,
              decoration: const InputDecoration(
                labelText: 'Tracking Link (URL)',
                hintText: 'https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGarnet),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onUpdateStatus(
                targetDocId,
                'delivering',
                '🛵 Out for Delivery',
                {
                  if (riderNameController.text.trim().isNotEmpty)
                    'riderName': riderNameController.text.trim(),
                  if (trackingLinkController.text.trim().isNotEmpty)
                    'trackingLink': trackingLinkController.text.trim(),
                },
              );
            },
            child: const Text('Dispatch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> order, String orderId, String status) {
    if (status == 'quote_received') {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: null,
        child: const Text('Awaiting Signature', style: TextStyle(color: Colors.grey, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'contract_signed') {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: null,
        child: const Text('Awaiting Payment', style: TextStyle(color: Colors.grey, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'pending_retainer_verification') {
      final bool isFull = order['paymentType'] == 'full';
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandRed,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => AdminModals.showPaymentVerificationModal(
          context,
          order,
          () => widget.onUpdateStatus(orderId, 'ready_to_bake', '✓ Ready for Oven'),
        ),
        child: Text(isFull ? 'Verify Full Payment' : 'Verify Retainer', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'ready_to_bake') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkEspresso,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => widget.onUpdateStatus(orderId, 'baking', '🍪 Baking & Preparation'),
        child: const Text('Start Bake', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'baking') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandCocoa,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          final bool isFullyPaid = order['paymentType'] == 'full';
          if (isFullyPaid) {
            _showDispatchDialog(context, orderId, order);
          } else {
            widget.onUpdateStatus(orderId, 'baked_payment_required', '💳 Awaiting Balance');
          }
        },
        child: const Text('Mark Baked', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'baked_payment_verifying') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandRed,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => AdminModals.showBalanceVerificationModal(
          context,
          order,
          () => _showDispatchDialog(context, orderId, order),
        ),
        child: const Text('Verify Balance', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'baked_payment_required') {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: null,
        child: const Text('Pending Balance', style: TextStyle(color: Colors.grey, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    if (status == 'delivering') {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: brandCocoa),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => AdminModals.showRiderTrackerModal(
          context,
          order,
          () => widget.onUpdateStatus(orderId, 'delivered', '✓ Completed Delivery'),
        ),
        child: const Text('Track Rider', style: TextStyle(color: brandCocoa, fontSize: 11.5, fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildScheduleAndSlotsView(List<Map<String, dynamic>> activeOrders, bool isMobile) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 950),
        child: _buildCalendarGrid(activeOrders, isMobile),
      ),
    );
  }

  void _showDayOrdersDialog(DateTime date, List<Map<String, dynamic>> orders) {
    final dateStr = DateFormat('MMMM d, yyyy').format(date);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cake_rounded, color: brandCocoa, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Orders for $dateStr',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: brandCocoa),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: brandCocoa),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: borderLight),
                if (orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No active orders for this date', style: TextStyle(color: textMuted, fontSize: 13))),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final order = orders[i];
                        final String customer = order['customer']?.toString() ?? 'Unknown';
                        final String orderId = order['id']?.toString() ?? order['docId']?.toString() ?? '';
                        final String payment = order['payment']?.toString().toLowerCase() ?? order['paymentType']?.toString().toLowerCase() ?? '';
                        final String status = order['status']?.toString() ?? '';
                        
                        String badgeText = 'PEND';
                        Color badgeBg = AppColors.brandRed;
                        Color badgeFg = AppColors.brandRed;

                        if (payment.contains('full')) {
                          badgeText = 'FULL';
                          badgeBg = AppColors.brandRed;
                          badgeFg = AppColors.brandRed;
                        } else if (payment.contains('half') || payment.contains('deposit')) {
                          badgeText = 'HALF';
                          badgeBg = AppColors.brandRed;
                          badgeFg = AppColors.brandRed;
                        } else if (status == 'baking' || status == 'ready_to_bake') {
                          badgeText = 'BAKI';
                          badgeBg = AppColors.bgPastelPink;
                          badgeFg = brandCocoa;
                        } else if (status.contains('quote') || status.contains('contract')) {
                          badgeText = 'QUOT';
                          badgeBg = AppColors.brandRed;
                          badgeFg = AppColors.brandRed;
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: wellBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.cake_rounded, color: brandCocoa, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: brandCocoa),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order['item']?.toString() ?? 'Custom Cake',
                                      style: const TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          orderId,
                                          style: const TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: badgeFg.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: badgeFg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
            ),
          ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildCalendarGrid(List<Map<String, dynamic>> activeOrders, bool isMobile) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    
    int offset = firstWeekday == 7 ? 0 : firstWeekday;
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    int totalReservedThisMonth = 0;
    Map<int, int> daysOrderCount = {};
    for (var o in activeOrders) {
      final targetField = o['targetDate'] ?? o['createdAt'];
      DateTime? td;
      if (targetField is Timestamp) td = targetField.toDate();
      else if (targetField != null) td = DateTime.tryParse(targetField.toString());
      if (td != null && td.month == _currentMonth.month && td.year == _currentMonth.year) {
        totalReservedThisMonth++;
        daysOrderCount[td.day] = (daysOrderCount[td.day] ?? 0) + 1;
      }
    }
    
    int totalCapacity = daysInMonth * 4; // 4 slots per day
    int available = totalCapacity - totalReservedThisMonth;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Baking Schedule & Slots',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: wellBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1)),
                      ),
                      Text(monthName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: wellBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '$totalReservedThisMonth/${totalCapacity} reserved',
                    style: const TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: borderLight),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((d) => 
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted),
                  ),
                )
              ).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 8 : 16, 0, isMobile ? 8 : 16, 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 42,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: isMobile ? 0.8 : 1.5,
                crossAxisSpacing: isMobile ? 4 : 8,
                mainAxisSpacing: isMobile ? 4 : 8,
              ),
              itemBuilder: (context, index) {
                int dayNumber = index - offset + 1;
                bool isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
                int dayCount = isCurrentMonth ? (daysOrderCount[dayNumber] ?? 0) : 0;
                
                return GestureDetector(
                  onTap: () {
                    if (isCurrentMonth) {
                      final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                      final ordersForDay = activeOrders.where((o) {
                        final targetField = o['targetDate'] ?? o['createdAt'];
                        DateTime? td;
                        if (targetField is Timestamp) td = targetField.toDate();
                        else if (targetField != null) td = DateTime.tryParse(targetField.toString());
                        return td != null && td.year == date.year && td.month == date.month && td.day == date.day;
                      }).toList();
                      _showDayOrdersDialog(date, ordersForDay);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentMonth ? Colors.white : AppColors.brandRed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                padding: const EdgeInsets.all(6),
                child: isCurrentMonth ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 12, 
                        color: isCurrentMonth ? textDark : textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (dayCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: wellBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cake_rounded, size: isMobile ? 10 : 8, color: brandCocoa),
                            if (!isMobile) ...[
                              const SizedBox(width: 3),
                              Text(
                                '$dayCount order${dayCount > 1 ? 's' : ''}',
                                style: const TextStyle(fontSize: 8, color: brandCocoa, fontWeight: FontWeight.bold),
                              ),
                            ] else ...[
                              const SizedBox(width: 2),
                              Text(
                                '$dayCount',
                                style: const TextStyle(fontSize: 9, color: brandCocoa, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ) : null,
                ),
              );
            },
            ),
          ),
        ],
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
                    color: AppColors.brandRed.withOpacity(0.08),
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
