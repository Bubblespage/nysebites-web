import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String _selectedSize = '6" Mini Tier (4-6 pax)';
  double _sizePriceModifier = 0.0;

  String _selectedBase = 'Classic Red Velvet';
  String _selectedFrosting = 'Whipped Cream Cheese';

  final List<String> _selectedToppings = [];
  final TextEditingController _pipingMessageController =
      TextEditingController();
  final TextEditingController _customNotesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _preferredImageBytes;
  String? _preferredImageName;

  final Map<String, double> _sizeOptions = {
    '6" Mini Tier (4-6 pax)': 0.0,
    '8" Standard Celebration (8-12 pax)': 350.0,
    '2-Tier Petite Tower (15-20 pax)': 800.0,
  };

  final List<String> _baseOptions = [
    'Classic Red Velvet',
    'Rich Belgian Chocolate Fudge',
    'Spiced Carrot Walnut',
    'Vanilla Butter Sponge',
  ];

  final List<String> _frostingOptions = [
    'Whipped Cream Cheese',
    'Dark Cocoa Ganache',
    'Salted Caramel Buttercream',
    'Oat Milk Vegan Frosting',
  ];

  final Map<String, double> _toppingsOptions = {
    '24K Edible Gold Flakes': 80.0,
    'Fresh Seasonal Berries': 120.0,
    'Crushed Lotus Biscoff': 60.0,
    'Toasted Almond Slices': 50.0,
    'Molten Chocolate Drip': 70.0,
  };

  double get _calculatedTotal {
    double total = widget.baseProduct.price + _sizePriceModifier;
    for (final topping in _selectedToppings) {
      total += _toppingsOptions[topping] ?? 0.0;
    }
    return total;
  }

  void _handleAddCustomCake() {
    final customDescription = StringBuffer();
    customDescription.write(
      'Size: $_selectedSize | Base: $_selectedBase | Frosting: $_selectedFrosting',
    );

    if (_selectedToppings.isNotEmpty) {
      customDescription.write(' | Toppings: ${_selectedToppings.join(", ")}');
    }
    if (_pipingMessageController.text.trim().isNotEmpty) {
      customDescription.write(
        ' | Message: "${_pipingMessageController.text.trim()}"',
      );
    }
    if (_customNotesController.text.trim().isNotEmpty) {
      customDescription.write(
        ' | Notes: ${_customNotesController.text.trim()}',
      );
    }
    if (_preferredImageName != null) {
      customDescription.write(
        ' | Preferred reference image: $_preferredImageName',
      );
    }

    final customizedCake = Product(
      id: DateTime.now().millisecondsSinceEpoch,
      name: 'Custom ${widget.baseProduct.name}',
      category: 'cakes',
      price: _calculatedTotal,
      description: customDescription.toString(),
      imgSrc: widget.baseProduct.imgSrc,
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
              // Header Preview
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(23),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: _preferredImageBytes != null
                          ? Image.memory(
                              _preferredImageBytes!,
                              fit: BoxFit.cover,
                            )
                          : widget.baseProduct.imgSrc.startsWith('http')
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
                    top: kIsWeb ? 12 : null,
                    bottom: kIsWeb ? null : 12,
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
                        'Customizing: ${widget.baseProduct.name}',
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

              // Customization Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!kIsWeb) _buildImagePickerControl(),
                      const SizedBox(height: 20),
                      // 1. Size
                      _sectionTitle('1. Choose Cake Size & Servings'),
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
                                setState(() {
                                  _selectedSize = val;
                                  _sizePriceModifier = entry.value;
                                });
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
                              entry.value == 0.0
                                  ? 'Included'
                                  : '+₱${entry.value.toStringAsFixed(0)}',
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

                      // 2. Base
                      _sectionTitle('2. Sponge Cake Base'),
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

                      // 3. Frosting
                      _sectionTitle('3. Frosting & Filling Style'),
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

                      // 4. Toppings
                      _sectionTitle('4. Premium Finishes & Toppings'),
                      const SizedBox(height: 10),
                      ..._toppingsOptions.entries.map((topping) {
                        final isChecked = _selectedToppings.contains(
                          topping.key,
                        );
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF8E4A23),
                          title: Text(
                            topping.key,
                            style: const TextStyle(fontSize: 13),
                          ),
                          secondary: Text(
                            '+₱${topping.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: Color(0xFF8E4A23),
                            ),
                          ),
                          value: isChecked,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedToppings.add(topping.key);
                              } else {
                                _selectedToppings.remove(topping.key);
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 18),

                      // 5. Piping Message Text Box
                      _sectionTitle('5. Cake Piping Message / Inscription'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pipingMessageController,
                        maxLength: 35,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2E1B10),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Happy 21st Birthday Shaina! 🎂',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E8E84),
                          ),
                          prefixIcon: const Icon(
                            Icons.border_color_outlined,
                            color: Color(0xFF8E4A23),
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEFE4D6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEFE4D6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF8E4A23),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 6. Special Customization & Baking Notes Text Box
                      _sectionTitle(
                        '6. Special Baking Instructions / Custom Notes',
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customNotesController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2E1B10),
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Less sweet frosting, vintage heart border, add 2 candles, allergen notice...',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E8E84),
                          ),
                          prefixIcon: const Icon(
                            Icons.edit_note,
                            color: Color(0xFF8E4A23),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEFE4D6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEFE4D6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF8E4A23),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      if (kIsWeb) ...[
                        const SizedBox(height: 18),
                        _buildImagePickerControl(),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
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
                        'Add Custom Cake to Tray',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Preferred Cake Reference Image'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickPreferredImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF2E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5D5C5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Color(0xFF8E4A23),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _preferredImageName ??
                        'Add a photo for your cake design reference',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A4438),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.upload_outlined,
                  color: Color(0xFF8E4A23),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
