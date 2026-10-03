import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../theme/app_colors.dart';

class MenuVerticalCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;
  final bool acceptCustomCakes;

  const MenuVerticalCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCustomize,
    this.acceptCustomCakes = true,
  });

  @override
  State<MenuVerticalCard> createState() => _MenuVerticalCardState();
}

class _MenuVerticalCardState extends State<MenuVerticalCard> {
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
      child: const Center(
        child: Icon(Icons.cookie, color: AppColors.brandRed, size: 40),
      ),
    );
  }

  void _handleAddToCart() {
    if (widget.product.category == 'cakes') {
      widget.onCustomize(widget.product);
    } else if (widget.product.category == 'cookies') {
      final selectedProduct = widget.product.copyWith(
        name: '${widget.product.name} (Box of 4)',
        servingSize: 'Box of 4',
      );
      widget.onAddToCart(selectedProduct);
    } else if (widget.product.servingSize != null) {
       final selectedProduct = widget.product.copyWith(
        name: '${widget.product.name} (${widget.product.servingSize})',
      );
      widget.onAddToCart(selectedProduct);
    } else {
      widget.onAddToCart(widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCake = widget.product.category == 'cakes';
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? AppColors.brandRed.withOpacity(0.3) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E151A).withOpacity(_isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Image
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildImage(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              widget.product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.textDarkBerry,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            
            // Description
            Expanded(
              child: Text(
                widget.product.description.isEmpty
                    ? 'Freshly baked for you with love and the finest ingredients.'
                    : widget.product.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            
            // Price and Add Button
            InkWell(
              onTap: (!widget.acceptCustomCakes && isCake) ? null : _handleAddToCart,
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: (!widget.acceptCustomCakes && isCake) 
                      ? Colors.grey[300] 
                      : (_isHovered ? AppColors.brandRed : Colors.white),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: (!widget.acceptCustomCakes && isCake) 
                        ? Colors.grey[400]! 
                        : AppColors.bgPastelPink,
                    width: 1.5,
                  ),
                  boxShadow: _isHovered && (!(!widget.acceptCustomCakes && isCake))
                      ? [
                          BoxShadow(
                            color: AppColors.brandRed.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (!widget.acceptCustomCakes && isCake) 
                          ? Icons.do_not_disturb_alt 
                          : isCake ? Icons.auto_awesome : Icons.add,
                      size: 16,
                      color: (!widget.acceptCustomCakes && isCake) 
                          ? Colors.grey[600] 
                          : (_isHovered ? Colors.white : AppColors.textDarkBerry),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (!widget.acceptCustomCakes && isCake)
                          ? 'Unavailable'
                          : isCake
                              ? 'Customize'
                              : 'Add • ₱${widget.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: (!widget.acceptCustomCakes && isCake) 
                          ? Colors.grey[600] 
                          : (_isHovered ? Colors.white : AppColors.textDarkBerry),
                      ),
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
