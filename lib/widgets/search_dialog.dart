import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../theme/app_colors.dart';
import '../widgets/horizontal_product_card.dart';

class SearchDialog extends StatefulWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> productsStream;
  final Function(Product) onAddToCart;
  final Function(Product) onCustomize;
  final bool acceptCustomCakes;
  final Set<String> favorites;
  final Function(Product)? onToggleFavorite;

  const SearchDialog({
    super.key,
    required this.productsStream,
    required this.onAddToCart,
    required this.onCustomize,
    required this.acceptCustomCakes,
    this.favorites = const {},
    this.onToggleFavorite,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search for treats...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textDarkBerry),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textDarkBerry),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textDarkBerry),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: widget.productsStream,
                builder: (context, snapshot) {
                  List<Product> rawList = [];

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    rawList = snapshot.data!.docs
                        .map((doc) => Product.fromMap(doc.id, doc.data()))
                        .toList();

                    final existingIds = rawList.map((p) => p.id.toString().replaceAll('sku_', '')).toList();
                    for (final mp in mockProducts) {
                      final index = existingIds.indexOf(mp.id.toString());
                      if (index == -1) {
                        rawList.add(mp);
                      } else {
                        rawList[index] = Product(
                          id: rawList[index].id,
                          name: mp.name,
                          order: mp.order,
                          category: mp.category,
                          price: mp.price,
                          priceBox6: mp.priceBox6,
                          servingSize: mp.servingSize,
                          description: mp.description,
                          imgSrc: mp.imgSrc,
                          icon: mp.icon,
                          stock: rawList[index].stock,
                          active: rawList[index].active,
                        );
                      }
                    }
                  } else {
                    rawList = List.from(mockProducts);
                  }

                  final List<Product> products = rawList
                      .where((p) => p.active && 
                        (p.name.toLowerCase().contains(_searchQuery) ||
                         p.description.toLowerCase().contains(_searchQuery) ||
                         p.category.toLowerCase().contains(_searchQuery)))
                      .toList();

                  products.sort((a, b) => a.order.compareTo(b.order));

                  if (_searchQuery.isEmpty) {
                    return Center(
                      child: Text(
                        'Type to search for your favorite treats.',
                        style: TextStyle(color: AppColors.textDarkBerry.withOpacity(0.6), fontSize: 16),
                      ),
                    );
                  }

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'No treats found for "$_searchQuery".',
                        style: TextStyle(color: AppColors.textDarkBerry.withOpacity(0.6), fontSize: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return HorizontalProductCard(
                        key: ValueKey(product.name),
                        product: product,
                        onAddToCart: (p) {
                          widget.onAddToCart(p);
                          Navigator.of(context).pop();
                        },
                        onCustomize: (p) {
                          widget.onCustomize(p);
                          Navigator.of(context).pop();
                        },
                        acceptCustomCakes: widget.acceptCustomCakes,
                        isFavorite: widget.favorites.contains(product.id.toString()),
                        onToggleFavorite: widget.onToggleFavorite ?? (p) {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
