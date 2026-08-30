import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert'; // Added to decode Base64 images

class AdminModals {
  static const Color brandCocoa = Color(0xFF3E2723);
  static const Color darkEspresso = Color(0xFF1F1209);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color wellBg = Color(0xFFF3F4F6);

  static String _cleanPdfCurrency(dynamic val) {
    if (val == null) return 'Php 0.00';
    final raw = val.toString();
    final numOnly = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsed = double.tryParse(numOnly);
    if (parsed != null) {
      return 'Php ${parsed.toStringAsFixed(2)}';
    }
    return 'Php 0.00';
  }

  // ── FIX: Smart Image Renderer ──
  // Checks if the string is an old Firebase URL or a new Base64 string 
  // and uses either Image.network or Image.memory to render it safely.
  static Widget _buildProofImage(
    BuildContext context,
    String? imageData, {
    double height = 220,
    String emptyLabel = 'No image provided',
  }) {
    if (imageData == null || imageData.trim().isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: wellBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderLight),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              color: textMuted,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              emptyLabel,
              style: const TextStyle(
                color: textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final bool isUrl = imageData.startsWith('http') || imageData.startsWith('https');

    Widget imageWidget;
    if (isUrl) {
      imageWidget = Image.network(
        imageData,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: brandCocoa,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text(
            'Unable to load URL image',
            style: TextStyle(color: textMuted, fontSize: 11.5),
          ),
        ),
      );
    } else {
      try {
        final bytes = base64Decode(imageData);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              'Unable to load Base64 image',
              style: TextStyle(color: textMuted, fontSize: 11.5),
            ),
          ),
        );
      } catch (e) {
        imageWidget = const Center(
          child: Text(
            'Invalid image format',
            style: TextStyle(color: textMuted, fontSize: 11.5),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageData, isUrl),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: wellBg,
              width: double.infinity,
              height: height,
              child: imageWidget,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.zoom_in_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showFullScreenImage(BuildContext context, String imageData, bool isUrl) {
    Widget imageWidget;
    if (isUrl) {
      imageWidget = Image.network(
        imageData,
        errorBuilder: (context, error, stackTrace) => const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Unable to load image',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      try {
        final bytes = base64Decode(imageData);
        imageWidget = Image.memory(
          bytes,
          errorBuilder: (context, error, stackTrace) => const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Unable to load image',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } catch (e) {
        imageWidget = const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Invalid image format',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: imageWidget,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Thermal Kitchen & Customer PDF Receipt
  static Future<pw.Document> _generateKitchenSlipPdf(
    Map<String, dynamic> order,
  ) async {
    final pdf = pw.Document();

    final String orderId =
        order['id']?.toString() ?? order['docId']?.toString() ?? 'NB-000000';
    final String customer = order['customer']?.toString() ?? 'Online Guest';
    final String phone =
        order['phone']?.toString() ?? order['contact']?.toString() ?? 'N/A';
    final String address = order['address']?.toString() ?? 'Standard Delivery';
    final String payment =
        order['payment']?.toString() ??
        order['paymentMethod']?.toString() ??
        'Cash on Delivery';
    final String item =
        order['item']?.toString() ??
        order['productName']?.toString() ??
        'Bakery Item';

    final String printDate = (order['printDate']?.toString() ?? 'Recent Order')
        .replaceAll('•', '-');
    final bool isCustom =
        order['isCustom'] == true ||
        item.toLowerCase().contains('custom') ||
        (order['category'] ?? '').toString().toLowerCase().contains('cake');

    final String size =
        order['size']?.toString() ??
        order['tier']?.toString() ??
        '6" Round Standard';
    final String flavor =
        order['flavor']?.toString() ??
        order['cakeFlavor']?.toString() ??
        'Signature Bake';
    final String frosting =
        order['frosting']?.toString() ?? 'Signature Frosting';
    final List toppings = (order['toppings'] is Iterable)
        ? (order['toppings'] as Iterable).toList()
        : [];

    final String pipingText =
        order['dedication']?.toString() ??
        order['pipingText']?.toString() ??
        order['piping']?.toString() ??
        order['cakeMessage']?.toString() ??
        (order['note'] != null && !order['note'].toString().contains('Delivery')
            ? order['note'].toString()
            : 'None');

    final double totalNum =
        double.tryParse(
          (order['total'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        1464.00;
    final double subtotalNum =
        double.tryParse(
          (order['subtotal'] ?? '0').toString().replaceAll(
            RegExp(r'[^0-9.]'),
            '',
          ),
        ) ??
        1400.00;
    final double deliveryFee = (totalNum - subtotalNum) > 0
        ? (totalNum - subtotalNum)
        : 64.00;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'NYSE BITES.',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Handcrafted Cookies, Brownies & Custom Cakes',
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'KITCHEN & DISPATCH SLIP',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  printDate,
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              ),
              pw.SizedBox(height: 8),

              _buildDashedLine(),
              pw.SizedBox(height: 5),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'ORDER #',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                  pw.Text(
                    orderId,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              _buildReceiptRow('Customer:', customer),
              _buildReceiptRow('Contact:', phone),
              _buildReceiptRow('Payment:', payment),
              _buildReceiptRow('Address:', address),

              pw.SizedBox(height: 5),
              _buildDashedLine(),
              pw.SizedBox(height: 6),

              pw.Text(
                item,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 4),

              if (isCustom) ...[
                _buildSpecLine('Size / Tier:', size),
                _buildSpecLine('Base Flavor:', flavor),
                _buildSpecLine('Frosting:', frosting),
                if (toppings.isNotEmpty)
                  _buildSpecLine('Toppings:', toppings.join(', ')),
                _buildSpecLine('Piping Note:', '"$pipingText"'),
                pw.SizedBox(height: 4),
              ],

              _buildDashedLine(),
              pw.SizedBox(height: 5),

              _buildReceiptRow(
                'Item Subtotal:',
                _cleanPdfCurrency(subtotalNum),
              ),
              _buildReceiptRow('Delivery Fee:', _cleanPdfCurrency(deliveryFee)),
              if (order['packagingFee'] != null && order['packagingFee'] > 0)
                _buildReceiptRow('Packaging Fee:', _cleanPdfCurrency(order['packagingFee'])),
              pw.SizedBox(height: 4),
              _buildDashedLine(),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL AMOUNT:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  pw.Text(
                    _cleanPdfCurrency(totalNum),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),
              pw.Center(
                child: pw.Text(
                  '*** THANK YOU FOR YOUR ORDER ***',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Baked with care in Imus, Cavite',
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildDashedLine() {
    return pw.Text(
      '----------------------------------------------------------',
      style: const pw.TextStyle(fontSize: 8),
      maxLines: 1,
    );
  }

  static pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSpecLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Slip Modal with PDF Preview, Save PDF & Direct Thermal Print
  static void showPrintSlipDialog(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final String orderId =
        order['id']?.toString() ?? order['docId']?.toString() ?? 'NB-000000';
    final String customer = order['customer']?.toString() ?? 'Online Guest';
    final String phone =
        order['phone']?.toString() ?? order['contact']?.toString() ?? 'N/A';
    final String address = order['address']?.toString() ?? 'Standard Delivery';
    final String payment =
        order['payment']?.toString() ??
        order['paymentMethod']?.toString() ??
        'Cash on Delivery';
    final String item =
        order['item']?.toString() ??
        order['productName']?.toString() ??
        'Bakery Item';

    final String printDate = order['printDate']?.toString() ?? 'Recent Order';

    final bool isCustom =
        order['isCustom'] == true ||
        item.toLowerCase().contains('custom') ||
        (order['category'] ?? '').toString().toLowerCase().contains('cake');

    final String size =
        order['size']?.toString() ??
        order['tier']?.toString() ??
        '6" Round Standard';
    final String flavor =
        order['flavor']?.toString() ??
        order['cakeFlavor']?.toString() ??
        'Signature Bake';
    final String frosting =
        order['frosting']?.toString() ?? 'Signature Frosting';
    final List toppings = (order['toppings'] is Iterable)
        ? (order['toppings'] as Iterable).toList()
        : [];

    final String pipingText =
        order['dedication']?.toString() ??
        order['pipingText']?.toString() ??
        order['piping']?.toString() ??
        order['cakeMessage']?.toString() ??
        (order['note'] != null && !order['note'].toString().contains('Delivery')
            ? order['note'].toString()
            : 'None');

    final String total = order['total']?.toString() ?? '₱0.00';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderLight),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(37, 24, 17, 0.12),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'NYSE BITES.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: darkEspresso,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'KITCHEN & BAKE PREP SLIP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: brandCocoa,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        printDate,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ORDER: $orderId',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: borderLight, thickness: 1),
                const SizedBox(height: 8),

                _buildSlipRow('Customer:', customer),
                _buildSlipRow('Contact:', phone),
                _buildSlipRow('Payment:', payment),
                _buildSlipRow('Delivery:', address),
                const SizedBox(height: 8),
                const Divider(color: borderLight, thickness: 1),
                const SizedBox(height: 8),

                Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),

                if (isCustom) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wellBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8DACB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎂 CAKE DECK SPECIFICATIONS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: brandCocoa,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildSpecItem('Size / Tier', size),
                        _buildSpecItem('Base Flavor', flavor),
                        _buildSpecItem('Frosting', frosting),
                        if (toppings.isNotEmpty)
                          _buildSpecItem('Toppings', toppings.join(', ')),
                        const Divider(color: Color(0xFFE8DACB), height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Piping: ',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '"$pipingText"',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: brandCocoa,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(color: borderLight, thickness: 1),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    Text(
                      total,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: brandCocoa,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: borderLight),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: brandCocoa),
                          foregroundColor: brandCocoa,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final pdfDoc = await _generateKitchenSlipPdf(order);
                          await Printing.sharePdf(
                            bytes: await pdfDoc.save(),
                            filename: 'Kitchen_Slip_$orderId.pdf',
                          );
                        },
                        icon: const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 16,
                        ),
                        label: const Text(
                          'Save PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandCocoa,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final pdfDoc = await _generateKitchenSlipPdf(order);
                          await Printing.layoutPdf(
                            name: 'Kitchen_Slip_$orderId',
                            onLayout: (PdfPageFormat format) async =>
                                pdfDoc.save(),
                          );
                        },
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text(
                          'Print',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 3. Add SKU Dialog
  static void showAddProductDialog(
    BuildContext context,
    Function(Map<String, dynamic>) onAddProduct,
  ) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final priceBox6Controller = TextEditingController();
    final stockController = TextEditingController(text: '20');
    final sizeController = TextEditingController(text: 'Box of 4');
    String selectedCategory = 'Cookies';
    String selectedIcon = '🍪';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFAFAFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Bake New SKU Drop',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: textDark,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Twix Chocolate Cookie',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: borderLight,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Cookies',
                                  child: Text('🍪 Cookies'),
                                ),
                                DropdownMenuItem(
                                  value: 'Brownies',
                                  child: Text('🍫 Brownies'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cakes',
                                  child: Text('🎂 Cakes'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedCategory = val;
                                    selectedIcon = val == 'Cookies'
                                        ? '🍪'
                                        : (val == 'Brownies' ? '🍫' : '🎂');
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price (Box of 4) ₱',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: '260.00',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: borderLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price (Box of 6) ₱ (Optional)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: priceBox6Controller,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: '390.00',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: borderLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Initial Stock',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: '20',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: borderLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandCocoa,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                final priceBox6 = double.tryParse(priceBox6Controller.text.trim());
                final stock = int.tryParse(stockController.text.trim()) ?? 0;

                if (name.isEmpty || price <= 0) return;

                final Map<String, dynamic> newProduct = {
                  'name': name,
                  'category': selectedCategory.toLowerCase(),
                  'price': price,
                  'stock': stock,
                  'servingSize': 'Box of 4',
                  'icon': selectedIcon,
                  'active': stock > 0,
                };

                if (priceBox6 != null && priceBox6 > 0) {
                  newProduct['priceBox6'] = priceBox6;
                }

                onAddProduct(newProduct);
                Navigator.pop(dialogCtx);
              },
              child: const Text(
                'Add SKU to Menu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Payment Verification Modal
  // ── FIX: Updated to look for the new Base64 string fields we added in the Tracker
  static void showPaymentVerificationModal(
    BuildContext context,
    Map<String, dynamic> order,
    VoidCallback onConfirm,
  ) {
    final String payment =
        (order['payment'] ?? order['paymentMethod'] ?? 'E-Wallet').toString();
    final String customer = (order['customer'] ?? 'Guest').toString();
    final String total = (order['total'] ?? '₱0.00').toString();

    final String paymentType = (order['paymentType'] ?? '').toString();
    String? refNumber;
    String? proofData; // Used for both URLs and Base64 strings

    if (paymentType == 'retainer') {
      refNumber = order['downPaymentReference']?.toString();
      proofData = order['downpaymentProofBase64']?.toString() ?? 
                  order['downPaymentProofBase64']?.toString() ?? 
                  order['downPaymentProofUrl']?.toString();
    } else if (paymentType == 'full') {
      refNumber = order['fullPaymentReference']?.toString();
      proofData = order['fullPaymentProofBase64']?.toString() ?? 
                  order['fullPaymentProofUrl']?.toString();
    } else {
      refNumber = order['referenceNumber']?.toString();
      proofData = order['paymentProofBase64']?.toString() ?? 
                  order['paymentProofUrl']?.toString();
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCF9F5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8D5C4), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(37, 24, 17, 0.18),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E5DA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: brandCocoa,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Verify $payment Payment',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16.5,
                            color: brandCocoa,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: textMuted, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm receipt of payment from $customer for the amount of $total before forwarding to the kitchen bake pipeline.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textMuted,
                            height: 1.4,
                          ),
                        ),
                        if (refNumber != null && refNumber.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: wellBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.tag, size: 14, color: brandCocoa),
                                const SizedBox(width: 6),
                                const Text(
                                  'Ref #: ',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    refNumber,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: brandCocoa,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'CUSTOMER PAYMENT SCREENSHOT',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: brandCocoa,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildProofImage(
                          context,
                          proofData,
                          height: 320,
                          emptyLabel: 'No screenshot uploaded',
                        ),
                        const SizedBox(height: 4),
                        if (proofData != null && proofData.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Tap the image to zoom in',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE8D5C4))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: borderLight),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandCocoa,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            onConfirm();
                          },
                          child: const Text(
                            'Confirm & Send to Bake',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 4.5 Balance Verification Modal
  // ── FIX: Updated to look for finalPaymentProofBase64
  static void showBalanceVerificationModal(
    BuildContext context,
    Map<String, dynamic> order,
    VoidCallback onConfirm,
  ) {
    final String customer = (order['customer'] ?? 'Guest').toString();
    final String balance =
        (order['balance']?.toString() ?? order['total']?.toString() ?? '₱0.00');
    final String? refNumber = order['balanceReference']?.toString();
    
    final String? proofData = order['finalPaymentProofBase64']?.toString() ?? 
                              order['finalPaymentProofUrl']?.toString();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCF9F5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8D5C4), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(37, 24, 17, 0.18),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E5DA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: brandCocoa,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Verify Final Balance',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16.5,
                            color: brandCocoa,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: textMuted, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm receipt of the remaining balance of $balance from $customer before dispatching for delivery.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textMuted,
                            height: 1.4,
                          ),
                        ),
                        if (refNumber != null && refNumber.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: wellBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.tag, size: 14, color: brandCocoa),
                                const SizedBox(width: 6),
                                const Text(
                                  'Ref #: ',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    refNumber,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: brandCocoa,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'CUSTOMER PAYMENT SCREENSHOT',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: brandCocoa,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildProofImage(
                          context,
                          proofData,
                          height: 320,
                          emptyLabel: 'No screenshot uploaded',
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE8D5C4))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: borderLight),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandCocoa,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            onConfirm();
                          },
                          child: const Text(
                            'Confirm & Deliver',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. Custom Cake Spec Inspection Drawer
  // ── FIX: Updated to look for referenceImageBase64
  static void showCustomCakeInspectionDrawer(
    BuildContext context,
    Map<String, dynamic> order,
    Function(double, double) onApprove,
    VoidCallback onReject,
  ) {
    final double initialBase = double.tryParse(
          (order['baseCakePrice'] ?? order['subtotal'] ?? 0.0).toString(),
        ) ??
        0.0;
    final TextEditingController baseController = TextEditingController(
      text: initialBase > 0 ? initialBase.toStringAsFixed(0) : '',
    );
    final TextEditingController addonController =
        TextEditingController(text: '300');

    final String orderId = (order['id'] ?? order['docId'] ?? '').toString();
    final String customer = (order['customer'] ?? 'Guest').toString();
    final String contact = (order['contact'] ?? '').toString();

    final List<dynamic> rawCustomCakes =
        order['customCakes'] is List ? order['customCakes'] as List : [];
    final List<Map<String, dynamic>> customCakes = rawCustomCakes
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (customCakes.isEmpty) {
      customCakes.add({
        'name': order['item']?.toString() ?? 'Custom Cake',
        'description': order['note']?.toString() ?? '',
        'referenceImageBase64': order['referenceImageBase64'] ?? order['referenceImageUrl'],
        'quantity': 1,
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 780),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8DACB), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(37, 24, 17, 0.18),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF2E9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    border: Border(bottom: BorderSide(color: Color(0xFFEFE4D6))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🎂', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Custom Cake Spec Review',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$orderId  •  $customer${contact.isNotEmpty ? '  •  $contact' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: textMuted, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < customCakes.length; i++) ...[
                          if (i != 0) const SizedBox(height: 14),
                          _buildCustomCakeSpecCard(context, customCakes[i]),
                        ],
                        const SizedBox(height: 20),
                        const Text(
                          'SET FINAL PRICE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: brandCocoa,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: baseController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Base Price (₱)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: borderLight),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: addonController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Addon Price (₱)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: borderLight),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFEFE4D6))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE57373)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            onReject();
                          },
                          child: const Text(
                            'Reject Spec',
                            style: TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandCocoa,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            final double base =
                                double.tryParse(baseController.text) ?? initialBase;
                            final double addon =
                                double.tryParse(addonController.text) ?? 300.0;
                            Navigator.pop(ctx);
                            onApprove(base, addon);
                          },
                          child: const Text(
                            'Approve & Send Quote',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildCustomCakeSpecCard(
    BuildContext context,
    Map<String, dynamic> cake,
  ) {
    final String name = (cake['name'] ?? 'Custom Cake').toString();
    final String description = (cake['description'] ?? '').toString();
    final int quantity =
        (cake['quantity'] is num) ? (cake['quantity'] as num).toInt() : 1;
        
    final String? imageString = cake['referenceImageBase64']?.toString() ?? 
                                cake['referenceImageUrl']?.toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quantity > 1 ? '${quantity}x $name' : name,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: textDark,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: textMuted, height: 1.35),
            ),
          ],
          const SizedBox(height: 10),
          const Text(
            'CUSTOMER REFERENCE IMAGE',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: brandCocoa,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _buildProofImage(
            context,
            imageString,
            height: 220,
            emptyLabel: 'No reference image provided',
          ),
        ],
      ),
    );
  }

  // 6. Rider Modal
  static void showRiderTrackerModal(
    BuildContext context,
    Map<String, dynamic> order,
    VoidCallback onComplete,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delivery Hand-off'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onComplete();
            },
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );
  }

  static Widget _buildSlipRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: textMuted)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: textDark)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }
}