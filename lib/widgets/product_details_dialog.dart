import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../data/mock_products.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final bool isFavorite;
  final Function(Product) onToggleFavorite;

  const ProductDetailsDialog({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  late bool _isFavorite;
  int _quantity = 1;
  bool _isBoxOf6 = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
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
      );
    } else if (isNetwork) {
      return Image.network(
        widget.product.imgSrc,
        fit: BoxFit.cover,
      );
    } else if (widget.product.imgSrc.isNotEmpty) {
      return Image.asset(
        widget.product.imgSrc,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        color: AppColors.bgPastelPink,
        alignment: Alignment.center,
        child: const Icon(Icons.bakery_dining, size: 64, color: AppColors.textDarkBerry),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 48),
      child: Container(
        width: isMobile ? double.infinity : 900,
        height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600,
        child: Stack(
          children: [
            // Main layouts taking full space
            Positioned.fill(
              child: isMobile 
                ? _buildMobileLayout(context) 
                : _buildDesktopLayout(context),
            ),
            
            // Close button floating at top right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textDarkBerry),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.bgPastelPink.withOpacity(0.7),
                  AppColors.bgPastelPink.withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E151A).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildImage(),
                  ),
                ),
              ),
            ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(right: 32.0, left: 32.0, bottom: 24.0, top: 48.0),
            child: _buildContent(context, isMobile: false),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgPastelPink.withOpacity(0.7),
                AppColors.bgPastelPink.withOpacity(0.2),
              ],
            ),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E151A).withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildImage(),
              ),
            ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: _buildContent(context, isMobile: true),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, {required bool isMobile}) {
    final titleDescPrice = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.product.name.toLowerCase(),
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkBerry,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(_isFavorite),
                  color: AppColors.brandRed,
                  size: isMobile ? 24 : 28,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                widget.onToggleFavorite(widget.product);
              },
            ),
          ],
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          widget.product.description.isEmpty 
              ? 'freshly baked for you with love and the finest ingredients.'
              : widget.product.description.toLowerCase(),
          style: TextStyle(
            fontSize: isMobile ? 13 : 15,
            color: Colors.grey[600],
            height: 1.4,
          ),
          maxLines: isMobile ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 12 : 20),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: AppColors.bgPastelPink,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.brandRed.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sell_outlined, color: AppColors.brandRed, size: isMobile ? 16 : 18),
              SizedBox(width: isMobile ? 6 : 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '₱${(_isBoxOf6 ? widget.product.priceBox6! : widget.product.price).toStringAsFixed(2)}',
                  key: ValueKey(_isBoxOf6),
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandRed,
                  ),
                ),
              ),
              if (widget.product.servingSize != null && widget.product.priceBox6 == null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.product.servingSize!,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brandRed,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final boxSizeSelection = widget.product.priceBox6 != null 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'choose box size',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 12 : 13, color: AppColors.textDarkBerry),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBoxOf6 = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: !_isBoxOf6 ? AppColors.brandRed : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: !_isBoxOf6 ? AppColors.brandRed : Colors.black12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Box of 4',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w800,
                            color: !_isBoxOf6 ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBoxOf6 = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: _isBoxOf6 ? AppColors.brandRed : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _isBoxOf6 ? AppColors.brandRed : Colors.black12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Box of 6',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w800,
                            color: _isBoxOf6 ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : null;

    final bool isCake = widget.product.category == 'cakes';

    final addToCartBlock = Row(
      children: [
        if (!isCake)
          Container(
          height: isMobile ? 40 : 46,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: isMobile ? 18 : 20, color: _quantity > 1 ? Colors.black87 : Colors.black26),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              SizedBox(
                width: isMobile ? 24 : 32,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    '$_quantity', 
                    key: ValueKey<int>(_quantity),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 15 : 16)
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: isMobile ? 18 : 20, color: Colors.black87),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
        if (!isCake) const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: isMobile ? 40 : 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Product productToAdd = widget.product;
                
                if (widget.product.priceBox6 != null) {
                  final boxLabel = _isBoxOf6 ? 'Box of 6' : 'Box of 4';
                  final selectedPrice = _isBoxOf6 ? widget.product.priceBox6! : widget.product.price;
                  if (!productToAdd.name.contains(boxLabel)) {
                    productToAdd = productToAdd.copyWith(
                      name: '${productToAdd.name} ($boxLabel)',
                      price: selectedPrice,
                    );
                  }
                } else if (widget.product.servingSize != null) {
                  if (!productToAdd.name.contains(widget.product.servingSize!)) {
                    productToAdd = productToAdd.copyWith(
                      name: '${productToAdd.name} (${widget.product.servingSize})',
                    );
                  }
                }

                Navigator.of(context).pop();
                for (int i = 0; i < _quantity; i++) {
                  widget.onAddToCart(productToAdd);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandRed,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.brandRed.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              icon: Icon(isCake ? Icons.edit : Icons.shopping_bag_outlined, size: isMobile ? 18 : 20),
              label: Text(
                isCake ? 'customize' : 'add to cart',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final allergensBlock = Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight_outlined, size: isMobile ? 16 : 18, color: AppColors.textDarkBerry),
              const SizedBox(width: 6),
              Text(
                'allergens & nutritional info',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkBerry,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'allergens',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandRed,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildAllergenPill('🌾 gluten'),
                        _buildAllergenPill('🥛 dairy'),
                        _buildAllergenPill('🥚 eggs'),
                        _buildAllergenPill('🥜 nuts (traces)'),
                        _buildAllergenPill('🫘 soy (traces)'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'nutritional information',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandRed,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildNutritionalRow('energy (kcal)', '280', '420', isMobile: isMobile),
                    _buildNutritionalRow('protein (g)', '4.5', '6.8', isMobile: isMobile),
                    _buildNutritionalRow('carbs (g)', '35.2', '52.8', isMobile: isMobile),
                    _buildNutritionalRow('sugar (g)', '18.4', '27.6', isMobile: isMobile),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isMobile) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleDescPrice,
            const SizedBox(height: 16),
            if (boxSizeSelection != null) ...[
              boxSizeSelection,
              const SizedBox(height: 16),
            ],
            addToCartBlock,
            if (!isCake) ...[
              const SizedBox(height: 16),
              allergensBlock,
            ],
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          titleDescPrice,
          if (boxSizeSelection != null) boxSizeSelection,
          addToCartBlock,
          if (!isCake) allergensBlock,
        ],
      );
    }
  }

  Widget _buildNutritionalRow(String label, String perServing, String per100g, {bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label, 
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 11 : 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              perServing, 
              style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              per100g, 
              style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.brandRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.brandRed,
        ),
      ),
    );
  }
}
