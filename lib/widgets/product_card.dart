import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCustomize,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  int _selectedCookieBoxSize = 4; // 4 or 6

  double get _currentPrice {
    if (widget.product.category == 'cookies') {
      if (_selectedCookieBoxSize == 6) {
        return widget.product.priceBox6 ?? 390.0;
      }
      return 260.0; // Box of 4 fixed price
    }
    return widget.product.price;
  }

  void _handleAddToCart() {
    if (widget.product.category == 'cookies') {
      final selectedProduct = Product(
        id: widget.product.id,
        name: '${widget.product.name} (Box of $_selectedCookieBoxSize)',
        category: widget.product.category,
        price: _currentPrice,
        description: widget.product.description,
        imgSrc: widget.product.imgSrc,
        servingSize: 'Box of $_selectedCookieBoxSize',
      );
      widget.onAddToCart(selectedProduct);
    } else {
      widget.onAddToCart(widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCake = widget.product.category == 'cakes';
    final isCookie = widget.product.category == 'cookies';
    
    // ── RELIABLE WIDTH CHECK FOR DESKTOP SITE MODE ──
    final flutterView = View.of(context);
    final physicalWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    final isNarrowCard = physicalWidth < 900;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF8E4A23)
                : const Color(0xFFEFE4D6),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(60, 34, 22, 0.08),
              blurRadius: _isHovered ? 18 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: SizedBox(
                    // FIX: Reduced from 180 to 165 to give the text area vertical breathing room!
                    height: isNarrowCard ? 125 : 165, 
                    width: double.infinity,
                    child: widget.product.imgSrc.startsWith('http')
                        ? Image.network(
                            widget.product.imgSrc,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildFallbackImage(),
                          )
                        : (widget.product.imgSrc.isNotEmpty
                            ? Image.asset(
                                widget.product.imgSrc,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackImage(),
                              )
                            : _buildFallbackImage()),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1B10).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                if (isCake)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E4A23),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 11,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'CUSTOMIZABLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // ── UNIFIED RESPONSIVE CONTENT AREA ──
            Expanded(
              child: Padding(
                // FIX: Clean, strict margins pushing the content slightly higher
                padding: const EdgeInsets.only(left: 15, right: 15, top: 14, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Perfect distribution
                  children: [
                    // --- TOP: Titles and Description ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: Color(0xFF2E1B10),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: Color(0xFF756256),
                          ),
                          maxLines: isNarrowCard ? 3 : 2, 
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    // --- BOTTOM: Options, Price, and Buttons ---
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Serving Size / Box Size Chips (ALWAYS ON TOP of Price)
                          if (isCookie)
                            Row(
                              children: [
                                _buildBoxSizeChip(4, 'Box of 4', compact: isNarrowCard),
                                const SizedBox(width: 6),
                                _buildBoxSizeChip(6, 'Box of 6', compact: isNarrowCard),
                              ],
                            )
                          else if (widget.product.servingSize != null && widget.product.servingSize!.isNotEmpty)
                            _buildServingBadge(),
                            
                          const SizedBox(height: 10), // Clean gap 
                          
                          // 2. Inline Price and Actions Row 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center, // Center aligns icons and text horizontally!
                            children: [
                              Text(
                                '₱${_currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.5,
                                  color: Color(0xFF8E4A23),
                                  height: 1.0, // Strict height keeps baseline aligned with icons
                                ),
                              ),
                              _buildActionButton(isCake),
                            ],
                          ),
                        ],
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

  Widget _buildServingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E7DC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5D5C5), width: 0.8),
      ),
      child: Text(
        widget.product.servingSize!,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF75492C),
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isCake) {
    final onTap = isCake
        ? () => widget.onCustomize(widget.product)
        : _handleAddToCart;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Favorite Button
        Material(
          color: widget.isFavorite ? const Color(0xFFFDE8E8) : const Color(0xFFFAF4ED),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: widget.onFavoriteToggle,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isFavorite ? const Color(0xFFE88B8B) : const Color(0xFFEFE4D6),
                  width: 1.2,
                ),
              ),
              child: Icon(
                widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: widget.isFavorite ? const Color(0xFFE53935) : const Color(0xFFDCC8B8),
                size: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Add / Build Button
        Material(
          color: isCake ? const Color(0xFF8E4A23) : const Color(0xFF2E1B10),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                isCake ? Icons.auto_awesome : Icons.add_shopping_cart,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoxSizeChip(int size, String label, {bool compact = false}) {
    final isSelected = _selectedCookieBoxSize == size;
    return InkWell(
      onTap: () => setState(() => _selectedCookieBoxSize = size),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8E4A23) : const Color(0xFFF9F5F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8E4A23)
                : const Color(0xFFE5D5C5),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 9.5 : 10.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF5A4438),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFF3E7DC),
      alignment: Alignment.center,
      child: const Icon(
        Icons.bakery_dining_outlined,
        size: 40,
        color: Color(0xFF8E4A23),
      ),
    );
  }
}