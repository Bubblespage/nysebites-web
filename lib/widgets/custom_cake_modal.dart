import 'package:flutter/material.dart';
import '../models/product.dart';

class CustomCakeModal extends StatefulWidget {
  final Product baseProduct;
  final ValueChanged<Product> onAddCustomCake;

  const CustomCakeModal({
    super.key,
    required this.baseProduct,
    required this.onAddCustomCake,
  });

  @override
  State<CustomCakeModal> createState() => _CustomCakeModalState();
}

class _CustomCakeModalState extends State<CustomCakeModal> {
  String _selectedSize = '6" Classic (4-6 pax)';
  double _sizePriceModifier = 0.0;

  String _selectedBase = 'Rich Dark Cocoa';
  String _selectedFrosting = 'Whipped Cream Cheese';

  final Set<String> _selectedToppings = {};
  final Map<String, double> _toppingPrices = {
    'Edible Gold Leaf': 50.0,
    'Fresh Strawberries': 80.0,
    'Crushed Brownie Bites': 60.0,
    'Belgian Choc Drizzle': 40.0,
  };

  final TextEditingController _customRequestController =
      TextEditingController();
  final TextEditingController _pipedTextController = TextEditingController();

  double get _computedTotalPrice {
    double total = widget.baseProduct.price + _sizePriceModifier;
    for (var topping in _selectedToppings) {
      total += _toppingPrices[topping] ?? 0.0;
    }
    return total;
  }

  @override
  void dispose() {
    _customRequestController.dispose();
    _pipedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF6F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Color(0xFFEFE4D6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cake_outlined, color: Color(0xFF8E4A23)),
                      const SizedBox(width: 10),
                      Text(
                        'Customize: ${widget.baseProduct.name}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E1B10),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF756256)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Customizer Options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Size Selection
                    _sectionTitle('1. Choose Cake Size'),
                    _buildSizeOption('6" Classic (4-6 pax)', 0.0),
                    _buildSizeOption('8" Grand Celebration (8-12 pax)', 250.0),
                    _buildSizeOption(
                      '2-Tier Party Showstopper (15-20 pax)',
                      650.0,
                    ),
                    const SizedBox(height: 20),

                    // Sponge Base Flavor
                    _sectionTitle('2. Select Sponge Base'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                                'Rich Dark Cocoa',
                                'Classic Moist Vanilla',
                                'Velvet Red Sponge',
                                'Uji Matcha Infusion',
                              ]
                              .map(
                                (base) => ChoiceChip(
                                  label: Text(base),
                                  selected: _selectedBase == base,
                                  selectedColor: const Color(0xFF3C2216),
                                  backgroundColor: const Color(0xFFFAF6F0),
                                  labelStyle: TextStyle(
                                    color: _selectedBase == base
                                        ? Colors.white
                                        : const Color(0xFF3C2216),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _selectedBase = base),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Frosting Flavor
                    _sectionTitle('3. Frosting Type'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                                'Whipped Cream Cheese',
                                'Swiss Dark Chocolate Ganache',
                                'Salted Butter Caramel Cream',
                              ]
                              .map(
                                (frosting) => ChoiceChip(
                                  label: Text(frosting),
                                  selected: _selectedFrosting == frosting,
                                  selectedColor: const Color(0xFF8E4A23),
                                  backgroundColor: const Color(0xFFFAF6F0),
                                  labelStyle: TextStyle(
                                    color: _selectedFrosting == frosting
                                        ? Colors.white
                                        : const Color(0xFF3C2216),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (_) => setState(
                                    () => _selectedFrosting = frosting,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Extra Toppings
                    _sectionTitle('4. Premium Toppings & Add-ons'),
                    ..._toppingPrices.entries.map((entry) {
                      final isChecked = _selectedToppings.contains(entry.key);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF8E4A23),
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E1B10),
                          ),
                        ),
                        secondary: Text(
                          '+₱${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E4A23),
                            fontSize: 12,
                          ),
                        ),
                        value: isChecked,
                        onChanged: (bool? val) {
                          setState(() {
                            if (val == true) {
                              _selectedToppings.add(entry.key);
                            } else {
                              _selectedToppings.remove(entry.key);
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 20),

                    // Custom Ingredients / Special Requests Box
                    _sectionTitle(
                      '5. Other Preferred Ingredients / Custom Request',
                    ),
                    const Text(
                      'Craving a specific flavor, ingredient, or allergen adjustment not listed above? Let our bakers know here:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF756256)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customRequestController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Please use oat milk for frosting, add espresso flavor to the base, or extra dark chocolate flakes...',
                        filled: true,
                        fillColor: const Color(0xFFFAF6F0),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFEFE4D6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFEFE4D6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Custom Piped Lettering
                    _sectionTitle('6. Custom Piped Message on Board / Cake'),
                    TextField(
                      controller: _pipedTextController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        hintText: 'e.g. Happy Birthday Shaina!',
                        filled: true,
                        fillColor: const Color(0xFFFAF6F0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFEFE4D6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFEFE4D6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modal Footer with Live Price & Add CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF6F0),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: Color(0xFFEFE4D6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Custom Price:',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF756256),
                        ),
                      ),
                      Text(
                        '₱${_computedTotalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
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
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      'Add Custom Cake',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final message = _pipedTextController.text.trim();
                      final customRequest = _customRequestController.text
                          .trim();

                      final List<String> details = [
                        '$_selectedBase sponge',
                        '$_selectedFrosting frosting',
                      ];

                      if (_selectedToppings.isNotEmpty) {
                        details.add(
                          'Toppings: ${_selectedToppings.join(", ")}',
                        );
                      }
                      if (customRequest.isNotEmpty) {
                        details.add('Custom Requests: "$customRequest"');
                      }
                      if (message.isNotEmpty) {
                        details.add('Piping: "$message"');
                      }

                      final customProduct = Product(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: '${widget.baseProduct.name} [$_selectedSize]',
                        category: 'cakes',
                        price: _computedTotalPrice,
                        description: details.join(' • '),
                        imageUrl: widget.baseProduct.imageUrl,
                      );

                      widget.onAddCustomCake(customProduct);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: Color(0xFF2E1B10),
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, double extra) {
    final isSelected = _selectedSize == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSize = label;
          _sizePriceModifier = extra;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E7DC) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8E4A23)
                : const Color(0xFFEFE4D6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF2E1B10),
                fontSize: 13,
              ),
            ),
            Text(
              extra == 0 ? 'Base' : '+₱${extra.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF8E4A23)
                    : const Color(0xFF756256),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
