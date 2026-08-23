import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CustomCakeModal extends StatefulWidget {
  final Product baseProduct;
  final Function(Product) onAddCustomCake;

  const CustomCakeModal({
    super.key,
    required this.baseProduct,
    required this.onAddCustomCake,
  });

  @override
  State<CustomCakeModal> createState() => _CustomCakeModalState();
}

class _CustomCakeModalState extends State<CustomCakeModal> {
  bool get _isStandardCake =>
      widget.baseProduct.name.contains('Pure Decadence');
  bool get _isOneTierCake => widget.baseProduct.name.contains('Vanilla Sky');

  late String _selectedSize;
  late Map<String, double> _sizeOptions;

  String _selectedBase = 'Chocolate';
  String _selectedFrosting = 'Chocolate';

  final TextEditingController _pipingMessageController =
      TextEditingController();
  final TextEditingController _customNotesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _preferredImageBytes;
  String? _preferredImageName;

  @override
  void initState() {
    super.initState();
    if (_isStandardCake) {
      _sizeOptions = {
        '6" x 2" Inches': 800.0,
        '6" x 4" Inches': 1000.0,
        '8" x 2" Inches': 1000.0,
        '8" x 4" Inches': 1200.0,
      };
    } else if (_isOneTierCake) {
      _sizeOptions = {
        '6" x 2" Inches (1 Layer)': 1450.0,
        '6" x 4" Inches (1 Layer)': 1650.0,
        '8" x 2" Inches (1 Layer)': 1650.0,
        '8" x 4" Inches (1 Layer)': 1850.0,
      };
    } else {
      // Lavender Noir (2 Tier)
      _sizeOptions = {
        '6" x 2" Inches (2 Layers)': 2500.0,
        '6" x 4" Inches (2 Layers)': 3000.0,
      };
    }
    _selectedSize = _sizeOptions.keys.first;
  }

  double get _calculatedTotal => _sizeOptions[_selectedSize] ?? 800.0;

  final List<String> _baseOptions = ['Chocolate', 'Vanilla', 'Ube'];
  final List<String> _frostingOptions = ['Chocolate', 'Vanilla'];

  void _handleAddCustomCake() {
    final customDescription = StringBuffer();
    customDescription.write(
      'Dimensions: $_selectedSize • Base: $_selectedBase • Icing: $_selectedFrosting (Included)',
    );

    if (_pipingMessageController.text.trim().isNotEmpty) {
      customDescription.write(
        ' • Piping: "${_pipingMessageController.text.trim()}"',
      );
    }
    if (_customNotesController.text.trim().isNotEmpty) {
      customDescription.write(
        ' • Notes: ${_customNotesController.text.trim()}',
      );
    }

    final customizedCake = Product(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: widget.baseProduct.name,
      category: 'cakes',
      price: _calculatedTotal,
      description: customDescription.toString(),
      imgSrc: widget.baseProduct.imgSrc,
      icon: '🎂',
    );

    widget.onAddCustomCake(customizedCake);
    Navigator.pop(context);
  }

  Future<void> _pickPreferredImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _preferredImageBytes = bytes;
      _preferredImageName = image.name;
    });
  }

  @override
  void dispose() {
    _pipingMessageController.dispose();
    _customNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 800),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEFE4D6)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(60, 34, 22, 0.16),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(23),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: widget.baseProduct.imgSrc.startsWith('http')
                          ? Image.network(
                              widget.baseProduct.imgSrc,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.baseProduct.imgSrc,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1B10).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _isStandardCake
                            ? 'Configuring Standard Cake'
                            : 'Customized: ${widget.baseProduct.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isStandardCake)
                      _sectionTitle('1. Cake Size & Dimensions'),
                      const SizedBox(height: 10),
                      ..._sizeOptions.entries.map((entry) {
                        final isSelected = _selectedSize == entry.key;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFAF2E9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF8E4A23)
                                  : const Color(0xFFEFE4D6),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: RadioListTile<String>(
                            value: entry.key,
                            groupValue: _selectedSize,
                            activeColor: const Color(0xFF8E4A23),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSize = val);
                              }
                            },
                            title: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            secondary: Text(
                              '₱${entry.value.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF8E4A23)
                                    : const Color(0xFF756256),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 18),
                      _sectionTitle('2. Cake Base'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _baseOptions.map((base) {
                          final isSelected = _selectedBase == base;
                          return ChoiceChip(
                            label: Text(base),
                            selected: isSelected,
                            selectedColor: const Color(0xFF8E4A23),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF3C2216),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 12.5,
                            ),
                            onSelected: (selected) {
                              if (selected)
                                setState(() => _selectedBase = base);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('3. Flavor Icing'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _frostingOptions.map((frosting) {
                          final isSelected = _selectedFrosting == frosting;
                          return ChoiceChip(
                            label: Text(frosting),
                            selected: isSelected,
                            selectedColor: const Color(0xFF8E4A23),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF3C2216),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 12.5,
                            ),
                            onSelected: (selected) {
                              if (selected)
                                setState(() => _selectedFrosting = frosting);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('4. Cake Piping Message / Inscription'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pipingMessageController,
                        maxLength: 35,
                        decoration: InputDecoration(
                          hintText: 'e.g. Happy Birthday Shaina! 🎂',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEFE4D6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle('5. Special Baking Instructions'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customNotesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Less sweet frosting, color theme preferences...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEFE4D6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle(
                        '6. Preferred Cake Reference Image (Optional)',
                      ),
                      const SizedBox(height: 8),
                      _buildImagePickerControl(),
                      const SizedBox(height: 16),
                      const Text(
                        'Note: Custom cakes require a 2-week reservation notice before delivery/pickup.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E4A23),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEFE4D6))),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(23),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Cake Price',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF756256),
                          ),
                        ),
                        Text(
                          '₱${_calculatedTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF8E4A23),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E4A23),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleAddCustomCake,
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text(
                        'Add Cake to Tray',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 14,
        color: Color(0xFF2E1B10),
      ),
    );
  }

  Widget _buildImagePickerControl() {
    return InkWell(
      onTap: _pickPreferredImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF2E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _preferredImageBytes != null
                ? const Color(0xFF8E4A23)
                : const Color(0xFFE5D5C5),
          ),
        ),
        child: Row(
          children: [
            if (_preferredImageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Image.memory(_preferredImageBytes!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              const Icon(
                Icons.add_photo_alternate_outlined,
                color: Color(0xFF8E4A23),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                _preferredImageName ??
                    'Upload sample cake photo from gallery...',
                style: const TextStyle(fontSize: 13, color: Color(0xFF5A4438)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
