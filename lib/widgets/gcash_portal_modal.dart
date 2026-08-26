import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class GCashPortalModal {
  static Future<bool?> show({
    required BuildContext context,
    required double amount,
    required String qrAssetPath,
    required Future<void> Function(
      String? referenceNumber,
      String? base64Screenshot,
    ) onSubmit,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GCashDialog(
        amount: amount,
        qrAssetPath: qrAssetPath,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _GCashDialog extends StatefulWidget {
  final double amount;
  final String qrAssetPath;
  final Future<void> Function(
    String? referenceNumber,
    String? base64Screenshot,
  ) onSubmit;

  const _GCashDialog({
    required this.amount,
    required this.qrAssetPath,
    required this.onSubmit,
  });

  @override
  State<_GCashDialog> createState() => _GCashDialogState();
}

class _GCashDialogState extends State<_GCashDialog> {
  final _refNumberController = TextEditingController();
  String? _paymentProofBase64;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickScreenshot() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _paymentProofBase64 = base64Encode(bytes);
          _errorMessage = null; // Clear error if they select an image
        });
      }
    } catch (e) {
      debugPrint('Error picking screenshot: $e');
    }
  }

  void _handleSubmit() async {
    final ref = _refNumberController.text.trim();
    if (ref.isEmpty && _paymentProofBase64 == null) {
      setState(() {
        _errorMessage = 'Please provide a Reference Number or upload a screenshot.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    
    try {
      await widget.onSubmit(ref.isEmpty ? null : ref, _paymentProofBase64);
      if (mounted) {
        setState(() => _isSuccess = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error submitting payment: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFF4F5F7),
      child: Column(
        children: [
          // Header (Full width)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0053E0), // GCash Blue
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GCash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // balance space for the close button
                ],
              ),
            ),
          ),


          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: isMobile ? 12.0 : 24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800), // wider card
                  child: Container(
                    padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 16 : 20, isMobile ? 16 : 24, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _isSuccess
                        ? [
                            const SizedBox(height: 24),
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 72,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Payment Submitted!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E3A5F),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Your order is now being processed.\n\nPlease refer to the Live Kitchen Tracker to monitor your order\'s progress.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4B5563),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0053E0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Track My Order',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ]
                        : [
                            const Text(
                              'Securely complete the payment with your GCash app',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7A8A9E),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Log in to GCash and scan this QR with the QR Scanner.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E3A5F),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                        
                        // QR Code (Cropped and Zoomed)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: FittedBox(
                            fit: BoxFit.none,
                            alignment: const Alignment(0, -0.05), // adjust vertical center
                            child: Transform.scale(
                              scale: 2.2, // zoom in on the QR
                              child: Image.asset(
                                widget.qrAssetPath,
                                width: 220,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₱${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0053E0),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Inputs
                        TextField(
                          controller: _refNumberController,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Reference Number (Optional)',
                            hintText: 'e.g. 1029384756',
                            prefixIcon: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF0053E0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0053E0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF0053E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _pickScreenshot,
                            icon: Icon(
                              _paymentProofBase64 == null
                                  ? Icons.add_photo_alternate
                                  : Icons.check_circle,
                            ),
                            label: Text(
                              _paymentProofBase64 == null
                                  ? 'Upload Screenshot Instead'
                                  : 'Screenshot Attached',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 12),

                        // Actions
                        if (isMobile) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0053E0),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Submit Payment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF8A8A8A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Color(0xFF8A8A8A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0053E0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isSubmitting ? null : _handleSubmit,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Submit Payment',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
