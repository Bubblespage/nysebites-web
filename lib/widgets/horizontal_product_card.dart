import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../theme/app_colors.dart';
import 'product_details_dialog.dart';

class HorizontalProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;
  final bool acceptCustomCakes;
  final bool isFavorite;
  final Function(Product) onToggleFavorite;

  const HorizontalProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCustomize,
    this.acceptCustomCakes = true,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<HorizontalProductCard> createState() => _HorizontalProductCardState();
}

class _HorizontalProductCardState extends State<HorizontalProductCard> {
  bool _isHovered = false;

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
  
  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.bgPastelPink,
      alignment: Alignment.center,
      child: const Icon(
        Icons.bakery_dining_outlined,
        size: 32,
        color: AppColors.textDarkBerry,
      ),
    );
  }

  void _handleAction([Product? customProduct]) {
    final productToAdd = customProduct ?? widget.product;
    if (productToAdd.category == 'cakes') {
      widget.onCustomize(productToAdd);
    } else {
      Product finalProduct = productToAdd;
      if (customProduct == null) {
        if (finalProduct.priceBox6 != null) {
          if (!finalProduct.name.contains('Box of 4')) {
            finalProduct = finalProduct.copyWith(name: '${finalProduct.name} (Box of 4)');
          }
        } else if (finalProduct.servingSize != null) {
          if (!finalProduct.name.contains(finalProduct.servingSize!)) {
            finalProduct = finalProduct.copyWith(name: '${finalProduct.name} (${finalProduct.servingSize})');
          }
        }
      }
      widget.onAddToCart(finalProduct);
    }
  }

  void _showDetails() {
    if (widget.product.category == 'cakes') {
      widget.onCustomize(widget.product);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ProductDetailsDialog(
        product: widget.product,
        onAddToCart: (p) => _handleAction(p),
        isFavorite: widget.isFavorite,
        onToggleFavorite: widget.onToggleFavorite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 12 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showDetails,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 10.0 : 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Square Image with rounded corners
                  Container(
                    width: isMobile ? 70 : 80,
                    height: isMobile ? 70 : 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
                      child: _buildImage(),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  
                  // Middle Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: isMobile ? 14 : 16,
                            color: AppColors.textDarkBerry,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description.isEmpty 
                              ? 'Freshly baked for you.'
                              : widget.product.description,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.grey[500],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        widget.product.category == 'cakes'
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 6 : 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bgPastelPink,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.brandRed.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: isMobile ? 10 : 12,
                                      color: AppColors.brandRed,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Customizable',
                                      style: TextStyle(
                                        fontSize: isMobile ? 9.5 : 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brandRed,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Text(
                                    '₱${widget.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: isMobile ? 14 : 16,
                                      color: AppColors.textDarkBerry,
                                    ),
                                  ),
                                  if (widget.product.servingSize != null) ...[
                                    SizedBox(width: isMobile ? 6 : 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgPastelPink.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.product.priceBox6 != null ? 'Box of 4 / 6' : widget.product.servingSize!,
                                        style: TextStyle(
                                          fontSize: isMobile ? 9 : 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.brandRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ],
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),

                  // Right Plus Button
                  GestureDetector(
                    onTap: _handleAction,
                    child: Container(
                      width: isMobile ? 28 : 32,
                      height: isMobile ? 28 : 32,
                      decoration: const BoxDecoration(
                        color: AppColors.darkGarnet, // Match the user's color theme but dark
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: isMobile ? 16 : 20,
                      ),
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
