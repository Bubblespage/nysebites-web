import 'package:flutter/material.dart';
import '../models/product.dart';

class CartDrawer extends StatelessWidget {
  final List<Product> cartItems;
  final double totalPrice;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onCheckout;

  const CartDrawer({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.onRemoveItem,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFAF6F0),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Color(0xFF8E4A23)),
                      const SizedBox(width: 8),
                      const Text(
                        'Your Sweet Tray',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2E1B10)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${cartItems.length})',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF756256), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF756256)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEFE4D6)),

            // Cart Items List
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cookie_outlined, size: 54, color: Color(0xFFDDB892)),
                          SizedBox(height: 12),
                          Text(
                            'Your tray is empty!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E1B10)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add your favorite treats from the menu.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF756256)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEFE4D6)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 46,
                                  height: 46,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.cookie, size: 30),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E1B10)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '₱${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF8E4A23), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFB54747), size: 20),
                                onPressed: () => onRemoveItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Order Total and Checkout
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEFE4D6))),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 14, color: Color(0xFF756256))),
                      Text('₱${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Packaging & Box', style: TextStyle(fontSize: 14, color: Color(0xFF756256))),
                      Text('FREE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFEFE4D6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF2E1B10)),
                      ),
                      Text(
                        '₱${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF8E4A23)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E4A23),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: cartItems.isEmpty ? null : onCheckout,
                      child: const Text(
                        'Confirm & Place Order',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
  }
}