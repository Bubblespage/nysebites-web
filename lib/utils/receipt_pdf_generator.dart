import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/product.dart';

class ReceiptPdfGenerator {
  static Future<void> generateAndPrintReceipt({
    required String orderId,
    required String customerName,
    required String contactNumber,
    required String deliveryAddress,
    required String deliveryType,
    required String paymentMethod,
    required List<Product> cartItems,
    required double subtotal,
    required double deliveryFee,
    required double packagingFee,
    required double grandTotal,
    String? referenceNumber,
    String? note,
  }) async {
    final pdf = pw.Document();

    // Group identical cart items
    final Map<String, int> grouped = {};
    final Map<String, double> itemPrices = {};
    for (final item in cartItems) {
      grouped[item.name] = (grouped[item.name] ?? 0) + 1;
      itemPrices[item.name] = item.price;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // Header & Bakery Branding
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NYSE BITES.',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#2E1B10'),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Artisanal Cookies & Celebration Cakes',
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColor.fromHex('#756256'),
                      ),
                    ),
                    pw.Text(
                      'Imus, Cavite, Philippines',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColor.fromHex('#756256'),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#FAF2E9'),
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColor.fromHex('#E5D5C5')),
                      ),
                      child: pw.Text(
                        'OFFICIAL ORDER RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#8E4A23'),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Order ID: $orderId',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Generated: ${DateTime.now().toLocal().toString().substring(0, 16)}',
                      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColor.fromHex('#E5D5C5'), thickness: 1, height: 22),

            // Customer & Delivery Details
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DELIVERY TO:',
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#8E4A23')),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(customerName, style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
                      pw.Text(deliveryAddress, style: const pw.TextStyle(fontSize: 9.5)),
                      pw.Text('Contact: $contactNumber', style: const pw.TextStyle(fontSize: 9.5)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FULFILLMENT & PAYMENT:',
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#8E4A23')),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('Speed: $deliveryType', style: const pw.TextStyle(fontSize: 9.5)),
                      pw.Text('Payment Method: $paymentMethod', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                      if (referenceNumber != null && referenceNumber.isNotEmpty)
                        pw.Text('Ref No: $referenceNumber', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      if (note != null && note.isNotEmpty)
                        pw.Text('Rider Note: "$note"', style: pw.TextStyle(fontSize: 8.5, fontStyle: pw.FontStyle.italic, color: PdfColors.grey800)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Itemized Table
            pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#F0E6DC'), width: 0.8),
                bottom: pw.BorderSide(color: PdfColor.fromHex('#E5D5C5'), width: 1),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(4),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FAF2E9')),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item Description', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Unit Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...grouped.entries.map((entry) {
                  final unitPrice = itemPrices[entry.key] ?? 0.0;
                  final total = unitPrice * entry.value;
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(entry.key, style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${entry.value}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('P${unitPrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('P${total.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 12),

            // Total Calculation Summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      _buildSummaryRow('Items Subtotal:', 'P${subtotal.toStringAsFixed(2)}'),
                      _buildSummaryRow('Delivery Fee:', deliveryFee == 0 ? 'FREE' : 'P${deliveryFee.toStringAsFixed(2)}'),
                      _buildSummaryRow('Thermal Packaging:', 'P${packagingFee.toStringAsFixed(2)}'),
                      pw.Divider(color: PdfColor.fromHex('#E5D5C5'), thickness: 1),
                      _buildSummaryRow(
                        'Grand Total:',
                        'P${grandTotal.toStringAsFixed(2)}',
                        isGrandTotal: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 18),

            // Footer
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FAF6F0'),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                children: [
                  pw.Text('Thank you for supporting small-batch handcrafted baking!', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#8E4A23'))),
                  pw.SizedBox(height: 2),
                  pw.Text('Freshly baked in Cavite • Store fresh cookies in airtight container for up to 5 days.', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_$orderId.pdf',
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isGrandTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isGrandTotal ? 10.5 : 9,
              fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isGrandTotal ? PdfColor.fromHex('#2E1B10') : PdfColor.fromHex('#756256'),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isGrandTotal ? 11 : 9,
              fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isGrandTotal ? PdfColor.fromHex('#8E4A23') : PdfColor.fromHex('#2E1B10'),
            ),
          ),
        ],
      ),
    );
  }
}