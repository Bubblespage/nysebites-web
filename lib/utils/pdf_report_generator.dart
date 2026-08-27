import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfReportGenerator {
  static final _headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.white);
  static const _cellStyle = pw.TextStyle(fontSize: 9);

  /// Strip emojis and any character outside the Latin-1 range that the
  /// default PDF (Helvetica) font cannot render.  The regex removes every
  /// code-point in the supplementary planes (U+10000+) which covers all
  /// modern emoji, as well as the peso sign ₱ (U+20B1) and similar symbols.
  static String _clean(String text) {
    // Remove emoji and other unsupported Unicode (supplementary planes)
    final noEmoji = text.replaceAll(RegExp(r'[\u{10000}-\u{10FFFF}]', unicode: true), '');
    // Also strip common symbols not in Helvetica: ₱ → P, ✅ → ✓ → plain
    return noEmoji
        .replaceAll('₱', 'P')
        .replaceAll('✅', '[OK]')
        .replaceAll('⏳', '[~]')
        .replaceAll('🎂', '')
        .replaceAll('📦', '')
        .replaceAll('🚗', '')
        .replaceAll('✓', 'OK')
        // remove any remaining non-Latin-1 characters
        .replaceAll(RegExp(r'[^\x00-\xFF]'), '?')
        .trim();
  }

  /// Normalise an amount string: strip ₱, PHP, commas; prefix with "PHP ".
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

  static pw.Widget _buildTable(List<String> headers, List<List<String>> data) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
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

  static Future<Uint8List> generateCustomCakesReport(List<Map<String, dynamic>> cakes, {String filterInfo = ''}) async {
    final pdf = pw.Document();

    final headers = ['Order ID', 'Target Date', 'Customer', 'Contact', 'Address', 'Specs', 'Amount', 'Status'];
    final data = cakes.map((cake) {
      return [
        _clean((cake['id'] ?? cake['docId'] ?? 'N/A').toString()),
        _formatDate(cake['targetDate'] ?? cake['createdAt']),
        _clean((cake['customerName'] ?? cake['customer'] ?? '').toString()),
        _clean((cake['contact'] ?? cake['phone'] ?? '').toString()),
        _clean((cake['address'] ?? cake['deliveryAddress'] ?? '').toString()),
        _clean('${cake['size'] ?? ''} - ${cake['flavor'] ?? ''}'),
        _cleanAmount(cake['total']),
        _clean((cake['statusLabel'] ?? cake['status'] ?? '').toString()),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Custom Cake Desk Requests${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateBatchMenuReport(List<Map<String, dynamic>> products, {String filterInfo = ''}) async {
    final pdf = pw.Document();

    final headers = ['Product ID', 'Name', 'Category', 'Price', 'Stock Status'];
    final data = products.map((prod) {
      return [
        _clean((prod['id'] ?? 'N/A').toString()),
        _clean((prod['name'] ?? '').toString()),
        _clean((prod['category'] ?? '').toString()),
        _cleanAmount(prod['price']),
        prod['inStock'] == true ? 'In Stock' : 'Sold Out',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Batch Drops & Menu Items${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateSweetNotesReport(List<Map<String, dynamic>> notes, {String filterInfo = ''}) async {
    final pdf = pw.Document();

    final headers = ['Date', 'Sender', 'Subject', 'Message'];
    final data = notes.map((note) {
      return [
        _formatDate(note['timestamp']),
        _clean((note['sender'] ?? '').toString()),
        _clean((note['subject'] ?? '').toString()),
        _clean((note['message'] ?? '').toString()),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _landscapePageTheme(),
        build: (context) => [
          _buildHeader('Sweet Notes Inbox${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
          _buildTable(headers, data),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateDashboardReport(Map<String, dynamic> stats, {String filterInfo = ''}) async {
    final pdf = pw.Document();

    // For dashboard we can do a mix of portrait layout or landscape blocks
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('Dashboard Overview Snapshot${filterInfo.isNotEmpty ? ' - $filterInfo' : ''}'),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Key Metrics', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Sales: P${stats['totalSales'] ?? '0.00'}', style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Total Orders: ${stats['totalOrders'] ?? '0'}', style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Pending Orders: ${stats['pendingOrders'] ?? '0'}', style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Completed Orders: ${stats['completedOrders'] ?? '0'}', style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
