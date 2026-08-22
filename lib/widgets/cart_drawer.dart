import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'checkout_modal.dart';

class CartDrawer extends StatefulWidget {
  final List<Product> cartItems;
  final double totalPrice;
  final Function(Product) onAddToCart;
  final Function(Product) onRemoveSingleItem;
  final Function(Product) onRemoveAllOfProduct;
  final VoidCallback onClearCart;
  final void Function(String orderId, int itemCount, double totalAmount) onOrderPlaced;
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

class _CartDrawerState extends State<CartDrawer> {
  static const Color brandCocoa = Color(0xFF8E4A23);
  static const Color darkEspresso = Color(0xFF2E1B10);
  static const Color borderLight = Color(0xFFEFE4D6);
  static const Color textMuted = Color(0xFF756256);

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

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedItems;
    final drawerWidth = MediaQuery.of(context).size.width < 460
        ? MediaQuery.of(context).size.width * 0.92
        : 420.0;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('settings').doc('storefront').snapshots(),
      builder: (context, snapshot) {
        final settings = snapshot.data?.data() ?? {};
        final bool isStoreOpen = settings['isStoreOpen'] ?? true;
        final double freeDeliveryThreshold =
            (settings['freeDeliveryMin'] ?? 1000.0).toDouble();

        final double amountToFreeDelivery = freeDeliveryThreshold - widget.totalPrice;
        final bool hasFreeDelivery = amountToFreeDelivery <= 0;
        final double freeDeliveryProgress =
            (widget.totalPrice / freeDeliveryThreshold).clamp(0.0, 1.0);

        return Drawer(
          width: drawerWidth,
          backgroundColor: const Color(0xFFFDFBF7),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                              border: Border.all(color: const Color(0xFFE5D5C5)),
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

                // Free Delivery Progress Meter
                if (widget.cartItems.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    color: const Color(0xFFFAF2E9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              hasFreeDelivery ? Icons.check_circle : Icons.local_shipping_outlined,
                              size: 16,
                              color: hasFreeDelivery ? const Color(0xFF2E7D32) : brandCocoa,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                hasFreeDelivery
                                    ? '🎉 You unlocked FREE doorstep delivery!'
                                    : 'Add ₱${amountToFreeDelivery.toStringAsFixed(2)} more for FREE Delivery!',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: hasFreeDelivery ? const Color(0xFF2E7D32) : darkEspresso,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: freeDeliveryProgress,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE8DACB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              hasFreeDelivery ? const Color(0xFF2E7D32) : brandCocoa,
                            ),
                          ),
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
                              Container(
                                width: 72,
                                height: 72,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E7DC),
                                  borderRadius: BorderRadius.circular(36),
                                  border: Border.all(color: const Color(0xFFE5D5C5)),
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
                              const SizedBox(height: 14),
                              const Text(
                                'Your tray is empty',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: darkEspresso,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Add freshly baked cookies and custom cakes!',
                                style: TextStyle(fontSize: 12, color: textMuted),
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
                            final items = grouped.values.elementAt(index);
                            final product = items.first;
                            final quantity = items.length;
                            final itemTotal = product.price * quantity;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: product.imgSrc.startsWith('http')
                                        ? Image.network(
                                            product.imgSrc,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            product.imgSrc,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE0D3C4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => widget.onRemoveSingleItem(product),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            quantity == 1
                                                ? Icons.delete_outline_rounded
                                                : Icons.remove,
                                            size: 16,
                                            color: quantity == 1 ? Colors.redAccent : darkEspresso,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(minWidth: 26),
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
                                        onTap: () => widget.onAddToCart(product),
                                        borderRadius: BorderRadius.circular(14),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.add,
                                            size: 16,
                                            color: brandCocoa,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
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
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isStoreOpen ? brandCocoa : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          onPressed: (!isStoreOpen || widget.cartItems.isEmpty)
                              ? null
                              : () => _openGrabStyleCheckout(context),
                          child: Text(
                            !isStoreOpen
                                ? 'Orders Temporarily Paused'
                                : 'Proceed to Checkout',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
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