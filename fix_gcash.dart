import "dart:io";

void main() {
  var f = File("lib/widgets/gcash_portal_modal.dart");
  var lines = f.readAsLinesSync();
  
  var before = lines.sublist(0, 379); 
  var after = lines.sublist(444); 
  
  var newWidget = '''                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.memory(
                                    _paymentProofBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black54,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    iconSize: 20,
                                    onPressed: () {
                                      setState(() {
                                        _paymentProofBytes = null;
                                        _paymentProofFileName = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    tooltip: 'Remove Image',
                                  ),
                                ),
                              ),
                            ],
                          ),''';
                          
  var result = before.join('\n') + '\n' + newWidget + '\n' + after.join('\n');
  f.writeAsStringSync(result);
  print("Lines replaced!");
}
