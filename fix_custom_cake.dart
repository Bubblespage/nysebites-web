import "dart:io";

void main() {
  var f = File("lib/widgets/custom_cake_modal.dart");
  var lines = f.readAsLinesSync();
  
  var before = lines.sublist(0, 903); 
  var after = lines.sublist(965); 
  
  var newWidget = '''  Widget _buildImagePickerControl() {
    if (_preferredImageBytes != null) {
      return Stack(
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
                _preferredImageBytes!,
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
                    _preferredImageBytes = null;
                    _preferredImageName = null;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Remove Image',
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _pickPreferredImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.bgPastelPink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textDarkBerry.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.textDarkBerry,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Upload sample cake photo from gallery...',
              style: const TextStyle(fontSize: 13, color: AppColors.textDarkBerry, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }''';
                          
  var result = before.join('\n') + '\n' + newWidget + '\n' + after.join('\n');
  f.writeAsStringSync(result);
  print("Lines replaced in custom_cake_modal!");
}
