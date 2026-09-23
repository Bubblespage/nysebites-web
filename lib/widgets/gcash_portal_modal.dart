import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../theme/app_colors.dart';

class GCashPortalModal {
  static Future<bool?> show({
    required BuildContext context,
    required double amount,
    required String qrAssetPath,
    required Future<void> Function(
      String? referenceNumber,
      Uint8List? paymentProofBytes,
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
    Uint8List? paymentProofBytes,
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
  Uint8List? _paymentProofBytes;
  String? _paymentProofFileName;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _isImageProcessing = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickScreenshot() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        // ── FIX: Compress the image so it fits inside Firestore's 1 MiB limit! ──
        maxWidth: 600,
        imageQuality: 50,
      );

      if (image != null) {
        setState(() {
          _isImageProcessing = true;
          _errorMessage = null;
        });

        final bytes = await image.readAsBytes();

        if (mounted) {
          setState(() {
            _paymentProofBytes = bytes;
            _paymentProofFileName = image.name;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking screenshot: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load image. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageProcessing = false;
        });
      }
    }
  }

  void _handleSubmit() async {
    final ref = _refNumberController.text.trim();
    if (ref.isEmpty && _paymentProofBytes == null) {
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
      await widget.onSubmit(ref.isEmpty ? null : ref, _paymentProofBytes);
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
      backgroundColor: AppColors.darkGarnet,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppColors.darkGarnet,
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
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: isMobile ? 12.0 : 24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
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
                              color: AppColors.brandRed,
                              size: 72,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Payment Submitted!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.brandRed,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Your order is now being processed.\n\nPlease refer to the Live Kitchen Tracker to monitor your order\'s progress.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.brandRed,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandRed,
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
                                color: AppColors.textDarkBerry,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Log in to GCash and scan this QR with the QR Scanner.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textDarkBerry,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.brandRed, width: 2),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: FittedBox(
                            fit: BoxFit.none,
                            alignment: const Alignment(0, -0.05),
                            child: Transform.scale(
                              scale: 2.2,
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
                            color: AppColors.textDarkBerry,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                              color: AppColors.brandRed,
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
                        if (_isImageProcessing)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.brandRed.withOpacity(0.3)),
                            ),
                            child: const Column(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.brandRed,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Processing Image...',
                                  style: TextStyle(
                                    color: AppColors.brandRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_paymentProofBytes == null)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.brandRed,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: AppColors.brandRed),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _pickScreenshot,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text(
                                'Upload Screenshot Instead',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.brandRed),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.brandRed),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.memory(
                                      _paymentProofBytes!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _paymentProofFileName ?? 'screenshot.png',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.brandRed,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Ready to submit',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.brandRed,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _paymentProofBytes = null;
                                      _paymentProofFileName = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close, color: AppColors.brandRed),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                          ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.brandRed),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.brandRed, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.brandRed,
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
                        if (isMobile) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandRed,
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
                                  color: AppColors.brandRed,
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
                                      color: AppColors.brandRed,
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
                                    backgroundColor: AppColors.brandRed,
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
