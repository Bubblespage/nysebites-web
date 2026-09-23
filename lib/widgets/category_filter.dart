import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
      {'label': 'All Sweets', 'sub': 'All Our Treats', 'value': 'all', 'image': 'assets/images/nyse_allsweets.jpg'},
      {'label': 'Cookies', 'sub': 'Soft & Chewy', 'value': 'cookies', 'image': 'assets/images/og.jpg'},
      {'label': 'Brownies', 'sub': 'Rich & Fudgy', 'value': 'brownies', 'image': 'assets/images/brownies.jpg'},
      {'label': 'Cake Loafs', 'sub': 'Moist & Sweet', 'value': 'cake loafs', 'image': 'assets/images/banana_cake_loaf.jpg'},
      {'label': 'Custom Cakes', 'sub': 'Celebration', 'value': 'cakes', 'image': 'assets/images/standard9_fixed.jpg'},
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;
    // Calculate card width for 2 columns on mobile. 
    // 32 is the total horizontal padding (16 * 2). 16 is the spacing between cards.
    final mobileCardWidth = (screenWidth - 32 - 16) / 2;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: 48.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderTitle(isMobile),
                    const SizedBox(height: 24),
                    _buildHeaderSubtext(isMobile, onSelectCategory),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildHeaderTitle(isMobile),
                    _buildHeaderSubtext(isMobile, onSelectCategory),
                  ],
                ),
          const SizedBox(height: 32),
          isMobile
              ? Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: categories.map((cat) => _buildCategoryCard(cat, isMobile, mobileCardWidth)).toList(),
                )
              : Row(
                  children: categories.map((cat) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: cat == categories.last ? 0 : 24.0,
                        ),
                        child: _buildCategoryCard(cat, isMobile, null),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Our\nCategories',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: isMobile ? 28 : 48,
                fontWeight: FontWeight.w900,
                color: AppColors.textDarkBerry,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(Icons.auto_awesome_outlined, color: AppColors.textDarkBerry, size: isMobile ? 24 : 32),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Transform.rotate(
          angle: -0.05,
          child: Container(
            width: isMobile ? 100 : 140,
            height: isMobile ? 6 : 8,
            decoration: BoxDecoration(
              color: AppColors.accentGold,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSubtext(bool isMobile, ValueChanged<String> onSelect) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          'From sweet treats to savory bites,\nfind your favorite baked delights.',
          textAlign: isMobile ? TextAlign.left : TextAlign.right,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textDarkBerry.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => onSelect('all'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'View Full Menu',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.textDarkBerry,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textDarkBerry),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat, bool isMobile, double? cardWidth) {
    final isSelected = selectedCategory == cat['value'];

    return GestureDetector(
      onTap: () => onSelectCategory(cat['value'] as String),
      child: Container(
        width: isMobile ? cardWidth : null,
        height: isMobile ? 220 : 280,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGarnet : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                cat['image'] as String,
                height: isMobile ? 110 : 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: isMobile ? 14 : 18,
                        color: isSelected ? Colors.white : AppColors.textDarkBerry,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['sub'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded, 
                              size: 16, 
                              color: AppColors.textDarkBerry
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_rounded, 
                            size: 20, 
                            color: Colors.grey[400]
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
