import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../theme/app_colors.dart';

class HorizontalProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;
  final bool acceptCustomCakes;

  const HorizontalProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCustomize,
    this.acceptCustomCakes = true,
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

  void _handleAction() {
    if (widget.product.category == 'cakes') {
      widget.onCustomize(widget.product);
    } else {
      widget.onAddToCart(widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: _handleAction,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Square Image with rounded corners
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildImage(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Middle Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
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
                            fontSize: 12,
                            color: Colors.grey[500],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.textDarkBerry,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right Plus Button
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.darkGarnet, // Match the user's color theme but dark
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
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
