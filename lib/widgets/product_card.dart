import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../theme/app_colors.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final double cardWidth;
  final bool isTopSeller;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCustomize,
    required this.cardWidth,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.isTopSeller = false,
  });

  static bool isNarrow(double cardWidth) => cardWidth < 230;

  static double imageHeight(double cardWidth) =>
      isNarrow(cardWidth) ? 140.0 : 180.0;

  static double computeHeight(double cardWidth) {
    // Increase height to accommodate the larger button
    return imageHeight(cardWidth) + 200.0; 
  }

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  int _selectedBoxSize = 4;

  @override
  void initState() {
    super.initState();
    _initBoxSize();
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.category != widget.product.category || oldWidget.product.id != widget.product.id) {
      _initBoxSize();
    }
  }

  void _initBoxSize() {
    if (widget.product.category == 'brownies') {
      _selectedBoxSize = 8;
    } else {
      _selectedBoxSize = 4;
    }
  }

  double get _currentPrice {
    if (widget.product.category == 'cookies') {
      if (_selectedBoxSize == 6) {
        return widget.product.priceBox6 ?? 390.0;
      }
      return 260.0; // Box of 4 fixed price
    }
    return widget.product.price;
  }

  void _handleAddToCart() {
    if (widget.product.category == 'cookies' || widget.product.category == 'brownies') {
      final selectedProduct = Product(
        id: widget.product.id,
        name: '${widget.product.name} (Box of $_selectedBoxSize)',
        category: widget.product.category,
        price: _currentPrice,
        description: widget.product.description,
        imgSrc: widget.product.imgSrc,
        servingSize: 'Box of $_selectedBoxSize',
      );
      widget.onAddToCart(selectedProduct);
    } else {
      widget.onAddToCart(widget.product);
    }
  }

  Widget _buildImage() {
    String mockImgSrc = '';
    try {
      final pName = widget.product.name.split('(').first.trim().toLowerCase();
      final match = mockProducts.firstWhere((p) {
        final catName = p.name.trim().toLowerCase();
        return catName.contains(pName) || pName.contains(catName);
      });
      mockImgSrc = match.imgSrc;
    } catch (_) {}

    final bool isNetwork = widget.product.imgSrc.startsWith('http');

    if (isNetwork && mockImgSrc.isNotEmpty) {
      return FadeInImage.assetNetwork(
        placeholder: mockImgSrc,
        image: widget.product.imgSrc,
        fit: BoxFit.cover,
        placeholderFit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 250),
        imageErrorBuilder: (_, __, ___) => _buildFallbackImage(),
        placeholderErrorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    } else if (isNetwork) {
      return Image.network(
        widget.product.imgSrc,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    } else if (widget.product.imgSrc.isNotEmpty) {
      return Image.asset(
        widget.product.imgSrc,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    } else {
      return _buildFallbackImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCake = widget.product.category == 'cakes';
    final isCookie = widget.product.category == 'cookies';
    final isBrownie = widget.product.category == 'brownies';
    final bool isNarrowCard = ProductCard.isNarrow(widget.cardWidth);

    final mq = MediaQuery.of(context);
    final clampedTextScaler = mq.textScaler.clamp(maxScaleFactor: 1.15);

    return MediaQuery(
      data: mq.copyWith(textScaler: clampedTextScaler),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Area
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: ProductCard.imageHeight(widget.cardWidth),
                        width: double.infinity,
                        child: _buildImage(),
                      ),
                    ),
                    if (widget.isTopSeller)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Bestseller',
                            style: TextStyle(
                              color: AppColors.textDarkBerry,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          onTap: widget.onFavoriteToggle,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: widget.isFavorite
                                  ? AppColors.brandRed
                                  : Colors.grey[400],
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textDarkBerry,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${_currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.textDarkBerry,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                          const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                          const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                          const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                          const Icon(Icons.star_half_rounded, color: AppColors.accentGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '(120)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (isCookie)
                        Row(
                          children: [
                            _buildBoxSizeChip(4, 'Box of 4', compact: isNarrowCard),
                            const SizedBox(width: 6),
                            _buildBoxSizeChip(6, 'Box of 6', compact: isNarrowCard),
                          ],
                        ),
                      if (isBrownie)
                        Row(
                          children: [
                            _buildBoxSizeChip(8, 'Box of 8', compact: isNarrowCard),
                          ],
                        ),

                      const Spacer(),

                      // Full width outlined button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: isCake
                              ? () => widget.onCustomize(widget.product)
                              : _handleAddToCart,
                          icon: Icon(
                            isCake ? Icons.auto_awesome : Icons.shopping_cart_outlined,
                            size: 16,
                          ),
                          label: Text(
                            isCake ? 'Customize' : 'Add to Cart',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textDarkBerry,
                            side: const BorderSide(color: AppColors.textDarkBerry, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxSizeChip(int size, String label, {bool compact = false}) {
    final isSelected = _selectedBoxSize == size;
    return InkWell(
      onTap: () => setState(() => _selectedBoxSize = size),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGarnet : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textDarkBerry,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.bgPastelPink,
      alignment: Alignment.center,
      child: const Icon(
        Icons.bakery_dining_outlined,
        size: 40,
        color: AppColors.textDarkBerry,
      ),
    );
  }
}
