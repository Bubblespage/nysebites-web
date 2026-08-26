import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import 'checkout_modal.dart';
import 'custom_cake_modal.dart';

class CartDrawer extends StatefulWidget {
  final List<Product> cartItems;
  final double totalPrice;
  final Function(Product) onAddToCart;
  final Function(Product) onRemoveSingleItem;
  final Function(Product) onRemoveAllOfProduct;
  final VoidCallback onClearCart;
  final void Function(String orderId, int itemCount, double totalAmount)
  onOrderPlaced;
  final String? currentUser;

  const CartDrawer({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.onAddToCart,
    required this.onRemoveSingleItem,
    required this.onRemoveAllOfProduct,
    required this.onClearCart,
    required this.onOrderPlaced,
    this.currentUser,
  });

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> with SingleTickerProviderStateMixin {
  static const Color brandCocoa = Color(0xFF3E2723);
  static const Color darkEspresso = Color(0xFF2E1B10);
  static const Color borderLight = Color(0xFFEFE4D6);
  static const Color textMuted = Color(0xFF756256);

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Map<String, List<Product>> get _groupedItems {
    final Map<String, List<Product>> grouped = {};
    for (final item in widget.cartItems) {
      final key = '${item.id}_${item.name}_${item.price}';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  void _openGrabStyleCheckout(BuildContext context) {
    if (widget.cartItems.isEmpty) return;

    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CheckoutModal(
        cartItems: widget.cartItems,
        totalAmount: widget.totalPrice,
        currentUser: widget.currentUser,
        onOrderSuccess: (orderId, itemCount, grandTotal, paymentMethod) {
          widget.onOrderPlaced(orderId, itemCount, grandTotal);
          widget.onClearCart();
        },
      ),
    );
  }

  String? _editingCookieKey;
  int? _tempCookieBoxSize;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedItems;
    final drawerWidth = MediaQuery.of(context).size.width < 460
        ? MediaQuery.of(context).size.width * 0.92
        : 420.0;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('settings')
          .doc('storefront')
          .snapshots(),
      builder: (context, snapshot) {
        final settings = snapshot.data?.data() ?? {};
        final bool isStoreOpen = settings['isStoreOpen'] ?? true;

        return Drawer(
          width: drawerWidth,
          backgroundColor: const Color(0xFFFAFAFA),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderLight)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E7DC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE5D5C5),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: darkEspresso,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Sweet Tray (${widget.cartItems.length})',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: darkEspresso,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Cart Item List
                Expanded(
                  child: grouped.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
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
                                  width: 72,
                                  height: 72,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E7DC),
                                    borderRadius: BorderRadius.circular(36),
                                    border: Border.all(
                                      color: const Color(0xFFE5D5C5),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    'assets/images/logo.jpg',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.cookie_outlined,
                                      size: 38,
                                      color: brandCocoa,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                              const Text(
                                'Your sweet tray is looking\na bit crumbly... 🍪',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkEspresso,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Let\'s add some treats!',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Add freshly baked cookies and custom cakes!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: grouped.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: borderLight, height: 24),
                          itemBuilder: (context, index) {
                            final itemKey = grouped.keys.elementAt(index);
                            final productList = grouped.values.elementAt(index);
                            final product = productList.first;
                            final quantity = productList.length;
                            final itemTotal = product.price * quantity;

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(40 * (1 - value), 0),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: product.imgSrc.isEmpty
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3E7DC),
                                              border: Border.all(color: const Color(0xFFE5D5C5)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              product.icon,
                                              style: const TextStyle(fontSize: 28),
                                            ),
                                          )
                                        : (product.imgSrc.startsWith('http')
                                            ? Image.network(
                                                product.imgSrc,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                product.imgSrc,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                  Icons.shopping_bag_outlined,
                                                  color: brandCocoa,
                                                ),
                                              )),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (_editingCookieKey == itemKey)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Edit Size: ${product.name.replaceAll(RegExp(r' \(Box of \d+\)'), '')}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: darkEspresso, fontSize: 13.5),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            ChoiceChip(
                                              label: const Text('Box of 4', style: TextStyle(fontSize: 12)),
                                              selected: _tempCookieBoxSize == 4,
                                              onSelected: (val) { if(val) setState(() => _tempCookieBoxSize = 4); },
                                              selectedColor: const Color(0xFFF3E7DC),
                                              checkmarkColor: brandCocoa,
                                              padding: EdgeInsets.zero,
                                            ),
                                            ChoiceChip(
                                              label: const Text('Box of 6', style: TextStyle(fontSize: 12)),
                                              selected: _tempCookieBoxSize == 6,
                                              onSelected: (val) { if(val) setState(() => _tempCookieBoxSize = 6); },
                                              selectedColor: const Color(0xFFF3E7DC),
                                              checkmarkColor: brandCocoa,
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () => setState(() => _editingCookieKey = null),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(50, 30),
                                              ),
                                              child: const Text('Cancel', style: TextStyle(color: textMuted, fontSize: 12)),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: brandCocoa,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                minimumSize: const Size(0, 30),
                                              ),
                                              onPressed: () {
                                                final baseProduct = mockProducts.firstWhere((p) => p.id == product.id, orElse: () => product);
                                                final updatedProduct = Product(
                                                  id: baseProduct.id,
                                                  name: '${baseProduct.name.replaceAll(RegExp(r' \(Box of \d+\)'), '')} (Box of $_tempCookieBoxSize)',
                                                  category: baseProduct.category,
                                                  price: _tempCookieBoxSize == 6 ? (baseProduct.priceBox6 ?? 390.0) : 260.0,
                                                  description: baseProduct.description,
                                                  imgSrc: baseProduct.imgSrc,
                                                  servingSize: 'Box of $_tempCookieBoxSize',
                                                );
                                                widget.onRemoveAllOfProduct(product);
                                                for (int i = 0; i < quantity; i++) {
                                                  widget.onAddToCart(updatedProduct);
                                                }
                                                setState(() => _editingCookieKey = null);
                                              },
                                              child: const Text('Save', style: TextStyle(fontSize: 12)),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                else ...[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13.5,
                                            color: darkEspresso,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (product.description.isNotEmpty && product.category.toLowerCase() == 'cakes') ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            margin: const EdgeInsets.only(right: 12),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9F6F0),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFEFE4D6)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: product.description.split(' • ').map((attr) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 3),
                                                  child: Text(
                                                    '• ${attr.trim()}',
                                                    style: const TextStyle(
                                                      fontSize: 10.5,
                                                      color: textMuted,
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 3),
                                        Text(
                                          '₱${itemTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.5,
                                            color: brandCocoa,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (product.category.toLowerCase() == 'cakes' || product.category.toLowerCase() == 'cookies')
                                      InkWell(
                                        onTap: () {
                                          if (product.category.toLowerCase() == 'cakes') {
                                            Navigator.pop(context); // close cart
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => CustomCakeModal(
                                                baseProduct: mockProducts.firstWhere(
                                                  (p) => p.name == product.name,
                                                  orElse: () => product,
                                                ),
                                                initialProduct: product,
                                                onAddCustomCake: (updatedProduct) {
                                                  widget.onRemoveAllOfProduct(product);
                                                  for (int i = 0; i < quantity; i++) {
                                                    widget.onAddToCart(updatedProduct);
                                                  }
                                                },
                                              ),
                                            );
                                          } else if (product.category.toLowerCase() == 'cookies') {
                                            setState(() {
                                              _editingCookieKey = itemKey;
                                              _tempCookieBoxSize = product.name.contains('Box of 6') ? 6 : 4;
                                            });
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.edit, size: 12, color: brandCocoa),
                                              SizedBox(width: 4),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: brandCocoa,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE0D3C4),
                                        ),
                                      ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            widget.onRemoveSingleItem(product),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            quantity == 1
                                                ? Icons.delete_outline_rounded
                                                : Icons.remove,
                                            size: 16,
                                            color: quantity == 1
                                                ? Colors.redAccent
                                                : darkEspresso,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 26,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: darkEspresso,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            widget.onAddToCart(product),
                                        borderRadius: BorderRadius.circular(14),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.add,
                                            size: 16,
                                            color: brandCocoa,
                                          ),
                                        ),
                                      ), // Closes InkWell
                                    ], // Closes inner Row children
                                  ), // Closes inner Row
                                ), // Closes Container
                                  ], // Closes Column children
                                ), // Closes Column
                              ] // Ends else branch for normal rendering
                            ], // Closes inner Row children
                        ), // Closes child Row
                      ); // Closes TweenAnimationBuilder
                    },
                  ),
                ),

                // Subtotal & Checkout Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: borderLight)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkEspresso,
                            ),
                          ),
                          Text(
                            '₱${widget.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: brandCocoa,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          final isEnabled = isStoreOpen && widget.cartItems.isNotEmpty;
                          return Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: isEnabled
                                  ? LinearGradient(
                                      colors: const [
                                        brandCocoa,
                                        Color(0xFF5A3E36),
                                        brandCocoa,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment(-2.0 + (_shimmerController.value * 4), 0.0),
                                      end: Alignment(0.0 + (_shimmerController.value * 4), 0.0),
                                    )
                                  : null,
                              color: !isEnabled ? Colors.grey : null,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: isEnabled
                                    ? () => _openGrabStyleCheckout(context)
                                    : null,
                                child: Center(
                                  child: Text(
                                    !isStoreOpen
                                        ? 'Orders Temporarily Paused'
                                        : 'Proceed to Checkout',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
