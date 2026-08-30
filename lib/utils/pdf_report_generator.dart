import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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