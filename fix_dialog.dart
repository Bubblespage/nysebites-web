import 'dart:io';

void main() {
  final files = [
    'lib/screens/admin/tabs/live_orders_tab.dart',
    'lib/screens/admin/tabs/custom_cake_desk_tab.dart',
  ];

  final replacement = """
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
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(37, 24, 17, 0.12),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dispatch Order',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF381014),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: riderNameController,
                decoration: InputDecoration(
                  labelText: 'Rider Details (Name / Plate No)',
                  hintText: 'e.g. Juan Dela Cruz - GrabCar',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF381014)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: trackingLinkController,
                decoration: InputDecoration(
                  labelText: 'Tracking Link (URL)',
                  hintText: 'https://...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF381014)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF381014),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onUpdateStatus(
                        targetDocId,
                        'delivering',
                        '🛵 Out for Delivery',
                        {
                          if (riderNameController.text.trim().isNotEmpty)
                            'riderName': riderNameController.text.trim(),
                          if (trackingLinkController.text.trim().isNotEmpty)
                            'trackingLink': trackingLinkController.text.trim(),
                        },
                      );
                    },
                    child: const Text('Dispatch', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }""";

  for (final file in files) {
    var content = File(file).readAsStringSync();
    
    final pattern = RegExp(
      r"showDialog\(\s*context: context,\s*builder: \(ctx\) => AlertDialog\([\s\S]*?child: const Text\('Dispatch', style: TextStyle\(color: Colors\.white\)\),\s*\),\s*\],\s*\),\s*\);\s*\}",
      multiLine: true
    );
    
    if (pattern.hasMatch(content)) {
      content = content.replaceFirst(pattern, replacement);
      File(file).writeAsStringSync(content);
      print('Updated ' + file);
    } else {
      print('Pattern not found in ' + file);
    }
  }
}
