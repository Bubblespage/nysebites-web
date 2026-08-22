import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminModals {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);
  static const Color wellBg = Color(0xFFF4EDE6);

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
                            filename: 'Kitchen_Slip_${orderId}.pdf',
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
    final stockController = TextEditingController(text: '20');
    final sizeController = TextEditingController();
    String selectedCategory = 'Cookies';
    String selectedIcon = '🍪';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFDFBF7),
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
              width: 400,
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
                      hintText: 'e.g. S’mores Campfire Cookie',
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
                              'Price (₱)',
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
                                hintText: '180.00',
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Portion / Size',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: sizeController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: '140g Palm-Sized',
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
                final price =
                    double.tryParse(priceController.text.trim()) ?? 0.0;
                final stock = int.tryParse(stockController.text.trim()) ?? 0;
                final size = sizeController.text.trim();

                if (name.isEmpty || price <= 0) return;

                onAddProduct({
                  'name': name,
                  'category': selectedCategory,
                  'price': price,
                  'stock': stock,
                  'size': size.isNotEmpty ? size : 'Standard Treat',
                  'icon': selectedIcon,
                  'active': stock > 0,
                });

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
  static void showPaymentVerificationModal(
    BuildContext context,
    Map<String, dynamic> order,
    VoidCallback onConfirm,
  ) {
    final String payment =
        order['payment'] ?? order['paymentMethod'] ?? 'E-Wallet';
    final String customer = order['customer'] ?? 'Guest';
    final String total = order['total'] ?? '₱0.00';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              color: Color(0xFF1967D2),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Verify $payment Payment',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Confirm receipt of payment from $customer for the amount of $total before forwarding to the kitchen bake pipeline.',
          style: const TextStyle(fontSize: 12.5, color: textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandCocoa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text(
              'Confirm & Send to Bake',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Custom Cake Spec Inspection Drawer
  static void showCustomCakeInspectionDrawer(
    BuildContext context,
    Map<String, dynamic> order,
    VoidCallback onApprove,
    VoidCallback onReject,
  ) {
    final String item = order['item'] ?? 'Custom Artisan Cake';
    final String tier = order['tier'] ?? 'Custom Celebration Tier';
    final String frosting = order['frosting'] ?? 'Signature Frosting';
    final String dedication =
        order['dedication'] ?? order['pipingText'] ?? order['note'] ?? 'None';
    final List toppings = (order['toppings'] is Iterable)
        ? (order['toppings'] as Iterable).toList()
        : [];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Text('🎂', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Custom Cake Spec Review',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tier: $tier',
              style: const TextStyle(fontSize: 12, color: textMuted),
            ),
            Text(
              'Frosting: $frosting',
              style: const TextStyle(fontSize: 12, color: textMuted),
            ),
            if (toppings.isNotEmpty)
              Text(
                'Toppings: ${toppings.join(', ')}',
                style: const TextStyle(fontSize: 12, color: textMuted),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: wellBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Piping Inscription: "$dedication"',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: brandCocoa,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onReject();
            },
            child: const Text(
              'Reject Spec',
              style: TextStyle(color: Color(0xFFC62828)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandCocoa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onApprove();
            },
            child: const Text(
              'Approve & Bake',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
    final String customer = order['customer'] ?? 'Guest';
    final String address = order['address'] ?? 'Standard Delivery Point';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.delivery_dining, color: Color(0xFF2E7D32), size: 22),
            SizedBox(width: 8),
            Text(
              'Dispatch & Delivery Hand-off',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: $customer',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Destination: $address',
              style: const TextStyle(fontSize: 12, color: textMuted),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mark this order as complete once the customer has received their sweet treats and payment is settled.',
              style: TextStyle(fontSize: 12, color: textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onComplete();
            },
            child: const Text(
              'Mark Completed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
