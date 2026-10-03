import 'dart:io';

void main() {
  final file = File(r'c:\Users\KBI\Desktop\NyseBites\nyse_bites\lib\widgets\order_tracker_modal.dart');
  String content = file.readAsStringSync().replaceAll('\r\n', '\n');

  // Part 1: Add state variable
  final stateSearch = '  String? _localStatus;\n  String? _localStatusLabel;\n\n  @override\n  void initState() {';
  final stateReplace = '  String? _localStatus;\n  String? _localStatusLabel;\n  bool _agreedToTerms = false;\n\n  @override\n  void initState() {';
  content = content.replaceFirst(stateSearch, stateReplace);

  // Part 2: Quote Received block
  final search = '''
                      const SizedBox(height: 6),
                      Text(
                        'Retainer Required to Secure Slot: ₱\${downPayment.toStringAsFixed(2)} (50%)',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Or Full Settlement: ₱\${total.toStringAsFixed(2)} (100%)',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
'''.replaceAll('\r\n', '\n');

  final replace = '''
                      const SizedBox(height: 6),
                      Text(
                        'Full Settlement Required: ₱\${total.toStringAsFixed(2)} (100%)',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 16),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
'''.replaceAll('\r\n', '\n');

  if (content.contains(search)) {
    content = content.replaceFirst(search, replace);
    print('Part 2 success');
  } else {
    print('Part 2 failed: could not find search string');
  }

  file.writeAsStringSync(content);
}
