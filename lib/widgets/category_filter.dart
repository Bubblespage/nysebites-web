import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'All Sweets', 'value': 'all'},
      {'label': 'Cookies', 'value': 'cookies'},
      {'label': 'Brownies', 'value': 'brownies'},
      {'label': 'Layer Cakes', 'value': 'cakes'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = selectedCategory == cat['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(cat['label']!),
                selected: isSelected,
                selectedColor: const Color(0xFF3C2216),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF756256),
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFEFE4D6)),
                ),
                onSelected: (_) => onSelectCategory(cat['value']!),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
