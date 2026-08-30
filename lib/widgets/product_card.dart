import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  // The actual rendered width this card will be given by the grid.
  // Driving the internal layout off this (instead of device width) means
  // the card looks identical for any device/browser that ends up giving
  // it the same width — desktop 4-col, tablet 3-col, or mobile 2-col.
  final double cardWidth;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCustomize,
    required this.cardWidth,
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

    // ── LAYOUT DRIVEN BY ACTUAL CARD WIDTH, NOT DEVICE WIDTH ──
    // This is what keeps the card's internal proportions (image height,
    // description line count, chip sizing) consistent no matter how many
    // columns the grid ends up rendering, or which device/browser it's on.
    final bool isNarrowCard = widget.cardWidth < 230;

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
                    height: isNarrowCard ? 125 : 150,
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
                
              ],
            ),

            // ── UNIFIED RESPONSIVE CONTENT AREA ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 12,
                  bottom: 7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Was MainAxisAlignment.spaceBetween — that pushed the price/
                  // button row all the way to the bottom of the card, so cards
                  // with shorter descriptions or no size chips (cakes/brownies)
                  // ended up with a big gap and the buttons floating low.
                  // MainAxisAlignment.start + a fixed gap keeps the button row
                  // sitting right under the text every time, consistently.
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            height: 1.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Fixed-height box (not just maxLines: 3) so a short
                        // 1-line description and a full 3-line description
                        // both occupy the same vertical space. Without this,
                        // cards with shorter text end their description
                        // block earlier, which shifts everything below it
                        // (badges, price, buttons) up relative to neighboring
                        // cards in the same grid row.
                        SizedBox(
                          height: 12 * 1.25 * 3, // fontSize * lineHeight * maxLines
                          child: Text(
                            widget.product.description,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: Color(0xFF756256),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Fixed gap instead of Spacer()/spaceBetween — keeps the
                    // bottom block anchored just under the description.
                    const SizedBox(height: 12),

                    // --- BOTTOM: Options, Price, and Buttons ---
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Serving Size / Box Size Chips (ALWAYS ON TOP of Price)
                          // Wrapped in a fixed-height SizedBox so cards with
                          // no chips/badge (e.g. cakes) still reserve the same
                          // vertical space as cards that do (cookies) — this
                          // is what keeps the price/button row aligned across
                          // every card in the same grid row.
                          SizedBox(
                            height: isNarrowCard ? 22 : 24,
                            child: isCookie
                                ? Row(
                                    children: [
                                      _buildBoxSizeChip(4, 'Box of 4',
                                          compact: isNarrowCard),
                                      const SizedBox(width: 6),
                                      _buildBoxSizeChip(6, 'Box of 6',
                                          compact: isNarrowCard),
                                    ],
                                  )
                                : (widget.product.servingSize != null &&
                                        widget.product.servingSize!.isNotEmpty
                                    ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: _buildServingBadge(),
                                      )
                                    : const SizedBox.shrink()),
                          ),

                          const SizedBox(height: 8),

                          // 2. Inline Price and Actions Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₱${_currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.5,
                                  color: Color(0xFF8E4A23),
                                  height: 1.0,
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
          color: widget.isFavorite
              ? const Color(0xFFFDE8E8)
              : const Color(0xFFFAF4ED),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: widget.onFavoriteToggle,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isFavorite
                      ? const Color(0xFFE88B8B)
                      : const Color(0xFFEFE4D6),
                  width: 1.2,
                ),
              ),
              child: Icon(
                widget.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: widget.isFavorite
                    ? const Color(0xFFE53935)
                    : const Color(0xFFDCC8B8),
                size: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Add / Build Button
        Material(
          color: isCake ? const Color(0xFF8E4A23) : const Color(0xFF2E1B10),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
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
          color:
              isSelected ? const Color(0xFF8E4A23) : const Color(0xFFF9F5F0),
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