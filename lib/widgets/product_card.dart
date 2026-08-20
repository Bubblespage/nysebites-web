import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onCustomize,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  int _selectedCookieBoxSize = 4; // 4 or 6

  double get _currentPrice {
    if (widget.product.category == 'cookies' && _selectedCookieBoxSize == 6) {
      return widget.product.priceBox6 ?? widget.product.price;
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
    final isNarrowCard = MediaQuery.of(context).size.width < 900;

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
            // Image Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: SizedBox(
                    height: isNarrowCard ? 110 : 180,
                    width: double.infinity,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        1.12,
                        0,
                        0,
                        0,
                        -8,
                        0,
                        1.12,
                        0,
                        0,
                        -8,
                        0,
                        0,
                        1.12,
                        0,
                        -8,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: widget.product.imgSrc.startsWith('http')
                          ? Image.network(
                              widget.product.imgSrc,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildFallbackImage(),
                            )
                          : Image.asset(
                              widget.product.imgSrc,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildFallbackImage(),
                            ),
                    ),
                  ),
                ),

                // Category Tag
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

                // Customizable Badge for Cakes
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

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isNarrowCard
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: Color(0xFF2E1B10),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isNarrowCard && isCookie) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildBoxSizeChip(4, 'Box of 4'),
                              const SizedBox(width: 6),
                              _buildBoxSizeChip(6, 'Box of 6'),
                            ],
                          ),
                        ],
                      ],
                    ),

                    // Price & Action Button
                    if (isNarrowCard)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildPriceRow(isCookie),
                                  if (isCookie) ...[
                                    const SizedBox(width: 5),
                                    _buildBoxSizeChip(
                                      4,
                                      'Box of 4',
                                      compact: true,
                                    ),
                                    const SizedBox(width: 4),
                                    _buildBoxSizeChip(
                                      6,
                                      'Box of 6',
                                      compact: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: _buildActionButton(isCake),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildPriceRow(isCookie),
                          _buildActionButton(isCake),
                        ],
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

  Widget _buildPriceRow(bool isCookie, {bool includeServing = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '₱${_currentPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.5,
            color: Color(0xFF8E4A23),
          ),
        ),
        if (includeServing &&
            !isCookie &&
            widget.product.servingSize != null) ...[
          const SizedBox(width: 6),
          _buildServingBadge(),
        ],
      ],
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

    return Material(
      color: isCake ? const Color(0xFF8E4A23) : const Color(0xFF2E1B10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCake ? Icons.cake_outlined : Icons.add_shopping_cart,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                isCake ? 'Build' : 'Add',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxSizeChip(int size, String label, {bool compact = false}) {
    final isSelected = _selectedCookieBoxSize == size;
    return InkWell(
      onTap: () => setState(() => _selectedCookieBoxSize = size),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 8,
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
            fontSize: compact ? 9 : 10.5,
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
