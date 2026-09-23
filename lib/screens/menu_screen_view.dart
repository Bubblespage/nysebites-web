import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../theme/app_colors.dart';
import '../widgets/horizontal_product_card.dart';

class MenuScreenView extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final Stream<QuerySnapshot<Map<String, dynamic>>> productsStream;
  final String? currentUser;
  final Set<String> favorites;
  final Function(Product) onAddToCart;
  final Function(Product) onToggleFavorite;
  final Function(Product) onCustomize;
  final bool acceptCustomCakes;
  final VoidCallback onBack;

  const MenuScreenView({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.productsStream,
    this.currentUser,
    required this.favorites,
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.onCustomize,
    required this.acceptCustomCakes,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: Container(
          color: AppColors.bgPastelPink,
          width: double.infinity,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 48.0,
                vertical: 48.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Left aligned
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textDarkBerry),
                          SizedBox(width: 8),
                          Text(
                            'Back to Home',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textDarkBerry,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildHeader(isMobile, context),
                  const SizedBox(height: 32),
                  _buildCategoryPills(isMobile),
                  const SizedBox(height: 48),
                  _buildProductGrid(isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildHeader(bool isMobile, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Our Menu',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: isMobile ? 32 : 42,
            fontWeight: FontWeight.w900,
            color: AppColors.textDarkBerry,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'From classic favorites to unique creations, we have something\nfor every craving.',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textDarkBerry.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPills(bool isMobile) {
    final categories = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Cookies', 'value': 'cookies'},
      {'label': 'Brownies', 'value': 'brownies'},
      {'label': 'Cake Loafs', 'value': 'cake loafs'},
      {'label': 'Custom Cakes', 'value': 'cakes'},
    ];

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: categories.map((cat) {
        final isSelected = selectedCategory == cat['value'];
        return InkWell(
          onTap: () => onCategoryChanged(cat['value']!),
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 28,
              vertical: isMobile ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.darkGarnet : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              cat['label']!,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isSelected ? Colors.white : AppColors.textDarkBerry,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductGrid(bool isMobile) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: productsStream,
      builder: (context, snapshot) {
        List<Product> rawList = [];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          rawList = snapshot.data!.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList();
          
          final existingIds = rawList.map((p) => p.id.toString().replaceAll('sku_', '')).toList();
          for (final mp in mockProducts) {
            final index = existingIds.indexOf(mp.id.toString());
            if (index == -1) {
              rawList.add(mp);
            } else {
              rawList[index] = Product(
                id: rawList[index].id,
                name: mp.name,
                order: mp.order,
                category: mp.category,
                price: mp.price,
                priceBox6: mp.priceBox6,
                servingSize: mp.servingSize,
                description: mp.description,
                imgSrc: mp.imgSrc,
                icon: mp.icon,
                stock: rawList[index].stock,
                active: rawList[index].active,
              );
            }
          }
        } else {
          rawList = List.from(mockProducts);
        }

        final List<Product> products = rawList
            .where((p) => p.active && (selectedCategory == 'all' || p.category == selectedCategory))
            .toList();

        products.sort((a, b) => a.order.compareTo(b.order));

        if (products.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: const Text(
              'No delicious treats match this category.',
              style: TextStyle(color: AppColors.textDarkBerry),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final columnCount = availableWidth <= 768 ? 1 : 2;
            final spacing = 20.0;
            
            // Increased to 130 to fix BOTTOM OVERFLOWED BY 6.0 PIXELS
            final double cardHeight = 130.0; 

            // Calculate minimum height based on the "All" category to prevent page jumpiness
            final int allProductsCount = rawList.where((p) => p.active).length;
            final int totalRows = (allProductsCount / columnCount).ceil();
            final double minGridHeight = totalRows * (cardHeight + spacing);

            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: minGridHeight),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                mainAxisExtent: cardHeight,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return HorizontalProductCard(
                  key: ValueKey(product.name),
                  product: product,
                  onAddToCart: onAddToCart,
                  onCustomize: onCustomize,
                  acceptCustomCakes: acceptCustomCakes,
                );
              },
            ));
          },
        );
      },
    );
  }
}
