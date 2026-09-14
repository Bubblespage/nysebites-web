import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfReportGenerator {
  static final _headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.white);
  static const _cellStyle = pw.TextStyle(fontSize: 9);

  static String _clean(String text) {
    final noEmoji = text.replaceAll(RegExp(r'[\u{10000}-\u{10FFFF}]', unicode: true), '');
    return noEmoji
        .replaceAll('₱', 'P')
        .replaceAll('✅', '[OK]')
        .replaceAll('⏳', '[~]')
        .replaceAll('🎂', '')
        .replaceAll('📦', '')
        .replaceAll('🚗', '')
        .replaceAll('✓', 'OK')
        .replaceAll(RegExp(r'[^\x00-\xFF]'), '?')
        .trim();
  }

  static String _cleanAmount(dynamic raw) {
    final str = raw?.toString() ?? '0.00';
    final digits = str.replaceAll(RegExp(r'[₱PHPphp,\s]'), '').trim();
    return 'PHP $digits';
  }

  static String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      date = DateTime.tryParse(timestamp.toString()) ?? DateTime.now();
    }
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static pw.PageTheme _landscapePageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(32),
    );
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('NYSE BITES - Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF8E4A23))),
        pw.SizedBox(height: 4),
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Generated: ${_formatDate(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildTable(List<String> headers, List<List<String>> data, {Map<int, pw.TableColumnWidth>? columnWidths}) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      columnWidths: columnWidths,
      headerStyle: _headerStyle,
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF8E4A23)),
      cellStyle: _cellStyle,
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignments: {
        for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF9F9F9)),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  // 1. LIVE ORDERS
  static Future<Uint8List> generateLiveOrdersReport(List<Map<String, dynamic>> orders, {String filterInfo = ''}) async {
    final pdf = pw.Document();
    final headers = ['Order ID', 'Date', 'Customer', 'Contact', 'Address', 'Item', 'Amount', 'Payment', 'Status'];
    final data = orders.map((order) {
      return [
        _clean((order['id'] ?? order['docId'] ?? 'N/A').toString()),
        _formatDate(order['createdAt']),
        _clean((order['customerName'] ?? order['customer'] ?? '').toString()),
        _clean((order['contact'] ?? order['phone'] ?? '').toString()),
        _clean((order['address'] ?? order['deliveryAddress'] ?? '').toString()),
        _clean((order['item'] ?? '').toString()),
        _cleanAmount(order['total']),
        _clean((order['payment'] ?? '').toString()),
        _clean((order['statusLabel'] ?? order['status'] ?? '').toString()),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Live Kitchen Pipeline${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data),
        ],
      ),
    );
    return pdf.save();
  }

  // 2. CUSTOM CAKES
  static Future<Uint8List> generateCustomCakesReport(List<Map<String, dynamic>> cakes, {String filterInfo = ''}) async {
    final pdf = pw.Document();
    final headers = ['Order ID', 'Customer Info', 'Cake Specs (Details)', 'Amount', 'Status'];

    final data = cakes.map((order) {
      final id = _clean((order['id'] ?? order['docId'] ?? 'N/A').toString());
      final customer = _clean((order['customerName'] ?? order['customer'] ?? 'Guest').toString());
      final phone = _clean((order['contact'] ?? order['phone'] ?? '').toString());
      final customerInfo = '$customer\n$phone';

      String specs = '';
      if (order['customCakes'] != null && (order['customCakes'] as List).isNotEmpty) {
        final customCakesList = order['customCakes'] as List;
        final List<String> specLines = [];
        for (var c in customCakesList) {
          final qty = c['quantity'] ?? 1;
          final name = c['name'] ?? 'Custom Cake';
          final desc = c['description']?.toString().replaceAll(' • ', '\n') ?? '';
          specLines.add('${qty}x $name\n$desc');
        }
        specs = specLines.join('\n\n');
      } else {
        final item = order['item'] ?? order['productName'] ?? 'Custom Cake';
        final tier = order['tier'] ?? '1 Tier';
        final frosting = order['frosting'] ?? 'Standard';
        final piping = order['dedication'] ?? order['pipingText'] ?? order['piping'] ?? 'No dedication';
        specs = '$item\nTier: $tier\nFrosting: $frosting\nPiping: "$piping"';
      }

      final amount = _cleanAmount(order['total'] ?? order['totalAmount'] ?? order['subtotal']);
      final status = _clean((order['statusLabel'] ?? order['status'] ?? '').toString());

      return [id, customerInfo, _clean(specs), amount, status];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Custom Cake Desk Requests${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data, columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(4.0),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(1.5),
          }),
        ],
      ),
    );
    return pdf.save();
  }

  // 3. BATCH MENU
  static Future<Uint8List> generateBatchMenuReport(List<Map<String, dynamic>> products, {String filterInfo = ''}) async {
    final pdf = pw.Document();
    final headers = ['SKU / ID', 'Product Details', 'Category & Size', 'Price', 'Stock & Status'];

    final data = products.map((prod) {
      final id = _clean((prod['id'] ?? prod['docId'] ?? 'N/A').toString());
      final name = _clean((prod['name'] ?? 'Unnamed Item').toString());
      final desc = _clean((prod['description'] ?? '').toString());
      final details = '$name${desc.isNotEmpty ? '\n$desc' : ''}';

      final category = _clean((prod['category'] ?? 'N/A').toString().toUpperCase());

      // Pull specific size/serving info or default to standard variants
      final size = _clean((prod['size'] ?? prod['servingSize'] ?? 'Box of 4').toString());

      // Handle dual box pricing if priceBox6 exists
      String priceStr = _cleanAmount(prod['price']);
      if (prod['priceBox6'] != null) {
        priceStr += '\nBox of 6: ${_cleanAmount(prod['priceBox6'])}';
      }

      final catAndSize = '$category\n$size';

      final stockNum = (prod['stock'] as num?)?.toInt() ?? 0;
      final isActive = prod['active'] == true;
      final statusText = isActive ? 'Active' : 'Hidden';
      final stockInfo = 'Stock: $stockNum\n$statusText';

      return [id, details, catAndSize, priceStr, stockInfo];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Batch Drops & Menu Items${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data, columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(3.5),
            2: const pw.FlexColumnWidth(1.8),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1.5),
          }),
        ],
      ),
    );
    return pdf.save();
  }

  // 4. SWEET NOTES
  static Future<Uint8List> generateSweetNotesReport(List<Map<String, dynamic>> notes, {String filterInfo = ''}) async {
    final pdf = pw.Document();
    final headers = ['Date', 'Sender', 'Subject', 'Message'];
    final data = notes.map((note) {
      return [
        _formatDate(note['createdAt'] ?? note['date']),
        _clean((note['name'] ?? note['sender'] ?? '').toString()),
        _clean((note['subject'] ?? '').toString()),
        _clean((note['message'] ?? '').toString()),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Sweet Notes Inbox${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data, columnWidths: {
            0: const pw.FlexColumnWidth(15),
            1: const pw.FlexColumnWidth(20),
            2: const pw.FlexColumnWidth(15),
            3: const pw.FlexColumnWidth(50),
          }),
        ],
      ),
    );
    return pdf.save();
  }

  // 5. DASHBOARD
  static Future<Uint8List> generateDashboardReport(Map<String, dynamic> stats, List<Map<String, dynamic>> orders, {String filterInfo = ''}) async {
    final pdf = pw.Document();

    final recentOrders = List<Map<String, dynamic>>.from(orders);
    recentOrders.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      if (aDate is Timestamp && bDate is Timestamp) return bDate.compareTo(aDate);
      return 0;
    });

    final headers = ['Order ID', 'Date', 'Customer', 'Item/s', 'Amount', 'Status'];
    final data = recentOrders.map((order) {
      return [
        _clean((order['id'] ?? order['docId'] ?? 'N/A').toString()),
        _formatDate(order['createdAt']),
        _clean((order['customerName'] ?? order['customer'] ?? 'Guest').toString()),
        _clean((order['item'] ?? order['productName'] ?? 'Custom Order').toString()),
        _cleanAmount(order['total'] ?? order['totalAmount'] ?? order['subtotal']),
        _clean((order['statusLabel'] ?? order['status'] ?? '').toString()),
      ];
    }).toList();

    final totalOrdersCount = stats['totalOrders'] ?? orders.length.toString();
    final customCakesCount = stats['customCakesCount'] ?? '0';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) {
          return [
            _buildHeader('Dashboard Overview Snapshot${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
            pw.SizedBox(height: 10),

            // MATCHING WEB DASHBOARD METRIC BOXES
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox('TOTAL REVENUE', 'PHP ${stats['totalSales'] ?? '0.00'}'),
                _buildStatBox('ACTIVE ORDERS', '$totalOrdersCount Orders\n$customCakesCount custom cakes'),
                _buildStatBox('BAKING IN OVEN', '${stats['bakingOrders'] ?? '0'} Batches'),
                _buildStatBox('DELIVERIES DONE', '${stats['completedOrders'] ?? '0'} Orders'),
              ]
            ),

            pw.SizedBox(height: 24),
            pw.Text('Comprehensive Transactions Log', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1B10))),
            pw.SizedBox(height: 10),
            _buildTable(headers, data, columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2.0),
              3: const pw.FlexColumnWidth(2.5),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.8),
            }),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // 6. CUSTOMER REVIEWS  (new)
  static Future<Uint8List> generateReviewsReport(List<Map<String, dynamic>> reviews, {String filterInfo = ''}) async {
    final pdf = pw.Document();
    final headers = ['Date', 'Customer', 'Product', 'Rating', 'Comment', 'Status'];

    final data = reviews.map((review) {
      final rating = review['rating'] is num ? (review['rating'] as num).toInt() : 5;
      return [
        _formatDate(review['createdAt']),
        _clean((review['userName'] ?? 'Anonymous').toString()),
        _clean((review['productName'] ?? 'Unknown Product').toString()),
        '$rating / 5',
        _clean((review['comment']?.toString().isNotEmpty == true
                ? review['comment']
                : 'No written feedback provided.')
            .toString()),
        _clean((review['status'] ?? 'new').toString()),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Customer Reviews${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data, columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.8),
            3: const pw.FlexColumnWidth(1.0),
            4: const pw.FlexColumnWidth(3.5),
            5: const pw.FlexColumnWidth(1.2),
          }),
        ],
      ),
    );
    return pdf.save();
  }

  // 7. E-RECEIPT (new)
  static Future<Uint8List> generateEReceiptPdf({
    required Map<String, dynamic> data,
    required String orderNumber,
    required List<Map<String, dynamic>> parsedItems,
    required String dateStr,
    required double subtotal,
    required double deliveryFee,
    required double packagingFee,
    required double total,
    required String paymentMethod,
    required String reference,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
  }) async {
    final pdf = pw.Document();

    final cocoa = const PdfColor.fromInt(0xFF8C4A27);
    final espresso = const PdfColor.fromInt(0xFF3E2723);
    final cream = const PdfColor.fromInt(0xFFFAF4ED);
    final muted = const PdfColor.fromInt(0xFF757575);
    final white = PdfColors.white;

    final int itemsCount = parsedItems.length;
    final int feesCount = (deliveryFee > 0 ? 1 : 0) + (packagingFee > 0 ? 1 : 0);
    final bool hasGCash = paymentMethod.toLowerCase().contains('gcash') && reference != 'N/A' && reference.isNotEmpty;

    double calculatedHeight = 420.0; // Base height (header, total, spacing)
    if (hasGCash) calculatedHeight += 20.0;
    if (customerPhone.isNotEmpty) calculatedHeight += 14.0;
    if (customerAddress.isNotEmpty) calculatedHeight += 24.0; // Assume address might wrap
    calculatedHeight += (itemsCount * 22.0);
    calculatedHeight += (feesCount * 20.0);

    final pageFormat = PdfPageFormat(400, calculatedHeight, marginAll: 0);

    final pageTheme = pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
      ),
    );

    const String receiptSvg = '''<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path d="M0 0h24v24H0z" fill="none"/><path d="M18 17H6v-2h12v2zm0-4H6v-2h12v2zm0-4H6V7h12v2zM3 22l1.5-1.5L6 22l1.5-1.5L9 22l1.5-1.5L12 22l1.5-1.5L15 22l1.5-1.5L18 22l1.5-1.5L21 22V2l-1.5 1.5L18 2l-1.5 1.5L15 2l-1.5 1.5L12 2l-1.5 1.5L9 2L7.5 3.5 6 2 4.5 3.5 3 2v20z" fill="white"/></svg>''';

    pw.Widget buildInfoRow(String label, String value, {pw.FontWeight weight = pw.FontWeight.bold}) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: muted, fontSize: 11)),
          pw.Text(value, style: pw.TextStyle(color: espresso, fontSize: 11, fontWeight: weight)),
        ],
      );
    }

    pw.Widget buildDivider() {
      return pw.Divider(color: const PdfColor.fromInt(0xFFE0E0E0), thickness: 1, borderStyle: pw.BorderStyle.dashed);
    }

    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            color: cream,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: cocoa,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                          ),
                          child: pw.SvgImage(svg: receiptSvg, width: 28, height: 28),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text('E-Receipt', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: espresso)),
                        pw.SizedBox(height: 4),
                        pw.Text(dateStr, style: pw.TextStyle(fontSize: 12, color: muted)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                buildDivider(),
                pw.SizedBox(height: 16),
                buildInfoRow('Order ID', orderNumber),
                pw.SizedBox(height: 8),
                buildInfoRow('Payment Method', paymentMethod),
                if (paymentMethod.toLowerCase().contains('gcash') && reference != 'N/A' && reference.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  buildInfoRow('GCash Ref', reference),
                ],
                pw.SizedBox(height: 12),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: espresso, fontSize: 12)),
                      if (customerPhone.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(customerPhone, style: pw.TextStyle(color: muted, fontSize: 11)),
                      ],
                      if (customerAddress.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(customerAddress, style: pw.TextStyle(color: muted, fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text('ITEMS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: muted, fontSize: 11, letterSpacing: 1.2)),
                pw.SizedBox(height: 8),
                ...parsedItems.map((item) {
                  final qty = item['quantity']?.toString() ?? '1';
                  final name = item['name']?.toString() ?? 'Item';
                  final priceVal = item['_calculatedPrice'] as double?;
                  
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${qty}x', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: espresso, fontSize: 12)),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: espresso, fontSize: 12)),
                        ),
                        pw.SizedBox(width: 8),
                        if (priceVal != null && priceVal > 0.0)
                          pw.Text('₱${priceVal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: espresso, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
                if (deliveryFee > 0 || packagingFee > 0) ...[
                  pw.SizedBox(height: 4),
                  if (deliveryFee > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: buildInfoRow('Delivery Fee', '₱${deliveryFee.toStringAsFixed(2)}', weight: pw.FontWeight.normal),
                    ),
                  if (packagingFee > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: buildInfoRow('Packaging Fee', '₱${packagingFee.toStringAsFixed(2)}', weight: pw.FontWeight.normal),
                    ),
                ],
                pw.SizedBox(height: 8),
                buildDivider(),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Amount', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: espresso)),
                    pw.Text('₱${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: cocoa)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStatBox(String title, String value) {
    return pw.Container(
      width: 135,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFAF2E9),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFEFE4D6)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF8E4A23))),
          pw.SizedBox(height: 6),
          pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF2E1B10))),
        ],
      ),
    );
  }
}