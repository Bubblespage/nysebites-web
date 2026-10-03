import 'dart:io';

void main() {
  final file = File(r'c:\Users\KBI\Desktop\NyseBites\nyse_bites\lib\widgets\order_tracker_modal.dart');
  // Need to read with correct fallback if it was messed up.
  // We'll just read as string, then replace the bad sequence.
  String content = file.readAsStringSync();
  content = content.replaceAll('â,±', '₱');
  file.writeAsStringSync(content);
}
