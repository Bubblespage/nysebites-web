import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../theme/app_colors.dart';
import '../widgets/horizontal_product_card.dart';
import '../widgets/product_card.dart';

class MenuScreenView extends StatelessWidget {
  final String selectedCategory;
  final String searchQuery;
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
    this.searchQuery = '',
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
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Container(
          color: AppColors.bgPastelPink,
          width: double.infinity,
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildHeader(isMobile, context), // Constrained Width Banner
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildCategoryPills(isMobile),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : 48.0,
                      vertical: 32.0,
                    ),
                    child: _buildProductGrid(isMobile),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.15, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
      builder: (context, scale, child) {
        return Container(
          width: double.infinity,
          height: isMobile
              ? 260.0
              : (MediaQuery.of(context).size.height * 0.55).clamp(350.0, 600.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E151A).withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: Image.network(
              'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&q=80',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryPills(bool isMobile) {
    final categories = [
      {'label': 'All', 'value': 'all', 'image': 'assets/images/all_sweets.jpg'},
      {
        'label': 'Cookies',
        'value': 'cookies',
        'image': 'assets/images/cookiesbatch.jpg',
      },
      {
        'label': 'Brownies',
        'value': 'brownies',
        'image': 'assets/images/brownies.jpg',
      },
      {
        'label': 'Cake Loafs',
        'value': 'cake loafs',
        'image': 'assets/images/banana_cake_loaf.jpg',
      },
      {
        'label': 'Custom Cakes',
        'value': 'cakes',
        'image': 'assets/images/1st_tier1.jpg',
      },
    ];

    final pillWidgets = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value;
      final isSelected = selectedCategory == cat['value'];

      return _CategoryPill(
        cat: cat,
        isSelected: isSelected,
        isMobile: isMobile,
        onTap: () => onCategoryChanged(cat['value'] as String),
        index: index,
      );
    }).toList();

    if (isMobile) {
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pillWidgets.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  right: entry.key == pillWidgets.length - 1 ? 0 : 8.0,
                ),
                child: entry.value,
              );
            }).toList(),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20.0,
          runSpacing: 20.0,
          children: pillWidgets,
        ),
      ),
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

          final existingIds = rawList
              .map((p) => p.id.toString().replaceAll('sku_', ''))
              .toList();
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
            .where(
              (p) =>
                  p.active &&
                  (selectedCategory == 'all' || p.category == selectedCategory),
            )
            .where(
              (p) =>
                  searchQuery.isEmpty ||
                  p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  p.description.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  p.category.toLowerCase().contains(searchQuery.toLowerCase()),
            )
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
            final isMobileView = availableWidth <= 650;
            
            final columnCount = isMobileView
                ? 1
                : (availableWidth <= 1000 ? 3 : 4);
            
            final spacing = isMobileView ? 16.0 : 20.0;
            
            final cardWidth = isMobileView
                ? availableWidth
                : (availableWidth - (columnCount - 1) * spacing) / columnCount;
            
            final double cardHeight = isMobileView
                ? 130.0
                : ProductCard.computeHeight(cardWidth);

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
                  if (isMobileView) {
                    return HorizontalProductCard(
                      key: ValueKey(product.name),
                      product: product,
                      onAddToCart: onAddToCart,
                      onCustomize: onCustomize,
                      acceptCustomCakes: acceptCustomCakes,
                      isFavorite: favorites.contains(product.id.toString()),
                      onToggleFavorite: onToggleFavorite,
                    );
                  } else {
                    return ProductCard(
                      key: ValueKey(product.name),
                      product: product,
                      cardWidth: cardWidth,
                      isTopSeller: false,
                      isFavorite: favorites.contains(product.id.toString()),
                      onFavoriteToggle: () {
                        onToggleFavorite(product);
                      },
                      onAddToCart: onAddToCart,
                      onCustomize: onCustomize,
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryPill extends StatefulWidget {
  final Map<String, dynamic> cat;
  final bool isSelected;
  final bool isMobile;
  final VoidCallback onTap;
  final int index;

  const _CategoryPill({
    required this.cat,
    required this.isSelected,
    required this.isMobile,
    required this.onTap,
    required this.index,
  });

  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                left: widget.isMobile ? 4 : 6,
                right: widget.isMobile ? (widget.isSelected ? 14 : 4) : 20,
                top: widget.isMobile ? 4 : 6,
                bottom: widget.isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.brandRed
                    : AppColors.bgPastelPink.withOpacity(0.95),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.brandRed
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppColors.brandRed.withOpacity(0.3)
                        : const Color(
                            0xFF2E151A,
                          ).withOpacity(_isHovered ? 0.12 : 0.04),
                    blurRadius: _isHovered || widget.isSelected ? 20 : 12,
                    offset: Offset(0, _isHovered ? 8 : 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: widget.isMobile ? 32 : 50,
                    height: widget.isMobile ? 32 : 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        widget.cat['image'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.isMobile || widget.isSelected)
                          SizedBox(width: widget.isMobile ? 6 : 12),
                        if (!widget.isMobile || widget.isSelected)
                          Text(
                            widget.cat['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: widget.isMobile ? 12 : 15,
                              color: widget.isSelected
                                  ? Colors.white
                                  : AppColors.textDarkBerry,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
