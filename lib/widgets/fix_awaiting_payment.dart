import 'dart:io';

void main() {
  final file = File(r'c:\Users\KBI\Desktop\NyseBites\nyse_bites\lib\widgets\order_tracker_modal.dart');
  String content = file.readAsStringSync().replaceAll('\r\n', '\n');

  // Part 1: Remove the 50% Retainer button and make the Full Amount button an ElevatedButton
  final searchAwaitingPayment = '''
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            GCashPortalModal.show(
                              context: context,
                              amount: downPayment,
                              qrAssetPath: 'assets/images/qr_code.jpg',
                              onSubmit: (ref, screenshot) => _processPayment(
                                ref: ref,
                                screenshot: screenshot,
                                stepKey: 'retainer',
                                statusValue: 'pending_retainer_verification',
                                statusLabelValue: '⏳ Verifying Retainer',
                                referenceField: 'downPaymentReference',
                                proofField: 'downpaymentProofBase64', // Note the Base64 field name
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 20),
                          label: const Text('Pay 50% Retainer (GCash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brandRed,
                            side: const BorderSide(color: AppColors.brandRed, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            GCashPortalModal.show(
                              context: context,
                              amount: total,
                              qrAssetPath: 'assets/images/qr_code.jpg',
                              onSubmit: (ref, screenshot) => _processPayment(
                                ref: ref,
                                screenshot: screenshot,
                                stepKey: 'full',
                                statusValue: 'pending_retainer_verification',
                                statusLabelValue: '⏳ Verifying Payment',
                                referenceField: 'fullPaymentReference',
                                proofField: 'fullPaymentProofBase64', // Note the Base64 field name
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 20),
                          label: const Text('Pay Full Amount (GCash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
'''.replaceAll('\r\n', '\n');

  final replaceAwaitingPayment = '''
                      // ── TERMS AND CONDITIONS ──
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandRed.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.brandRed.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: AppColors.brandRed,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'I agree to the Contract Terms & Conditions. I acknowledge that custom cake orders are non-cancellable and require full payment upfront to verify the order and begin production.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkGarnet,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_agreedToTerms)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            GCashPortalModal.show(
                              context: context,
                              amount: total,
                              qrAssetPath: 'assets/images/qr_code.jpg',
                              onSubmit: (ref, screenshot) => _processPayment(
                                ref: ref,
                                screenshot: screenshot,
                                stepKey: 'full',
                                statusValue: 'pending_retainer_verification',
                                statusLabelValue: '⏳ Verifying Payment',
                                referenceField: 'fullPaymentReference',
                                proofField: 'fullPaymentProofBase64', // Note the Base64 field name
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner, size: 20),
                          label: const Text('Pay Full Amount (GCash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
'''.replaceAll('\r\n', '\n');

  if (content.contains(searchAwaitingPayment)) {
    content = content.replaceFirst(searchAwaitingPayment, replaceAwaitingPayment);
    print('Awaiting payment fix success');
  } else {
    print('Awaiting payment fix failed');
  }

  // Part 2: Restore the "Accept Quote" button to NOT require the checkbox, since we moved it.
  final searchQuote = '''
                      // ── TERMS AND CONDITIONS ──
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandRed.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.brandRed.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: AppColors.brandRed,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'I agree to the Contract Terms & Conditions. I acknowledge that custom cake orders are non-cancellable and require full payment upfront to verify the order and begin production.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkGarnet,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_agreedToTerms)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
'''.replaceAll('\r\n', '\n');

  final replaceQuote = '''
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
'''.replaceAll('\r\n', '\n');

  if (content.contains(searchQuote)) {
    content = content.replaceFirst(searchQuote, replaceQuote);
    print('Quote button fix success');
  } else {
    print('Quote button fix failed');
  }

  file.writeAsStringSync(content);
}
