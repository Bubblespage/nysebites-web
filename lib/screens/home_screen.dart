import 'package:flutter/material.dart';
import '../data/mock_products.dart';
import '../models/product.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/category_filter.dart';
import '../widgets/custom_cake_modal.dart';
import '../widgets/footer.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/reviews_slideshow.dart';
import '../widgets/settings_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'all';
  String _searchQuery = '';
  final List<Product> _cart = [];

  // Settings State
  bool _nutFreeFilter = false;
  String _sweetnessLevel = '100% Regular Sweet';
  bool _ecoPackaging = true;

  List<Product> get _filteredProducts {
    return mockProducts.where((p) {
      final matchesCategory =
          _selectedCategory == 'all' || p.category == _selectedCategory;
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesNutFree =
          !_nutFreeFilter || !p.description.toLowerCase().contains('walnut');

      return matchesCategory && matchesSearch && matchesNutFree;
    }).toList();
  }

  double get _cartTotal => _cart.fold(0.0, (sum, item) => sum + item.price);

  void _scrollToMenu() {
    _scrollController.animateTo(
      600,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _addToCart(Product product) {
    setState(() => _cart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${product.name}" to tray!'),
        action: SnackBarAction(
          label: 'VIEW TRAY',
          textColor: const Color(0xFFDDB892),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCustomCakeBuilder(Product cakeProduct) {
    showDialog(
      context: context,
      builder: (context) => CustomCakeModal(
        baseProduct: cakeProduct,
        onAddCustomCake: _addToCart,
      ),
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsModal(
        nutFreeFilter: _nutFreeFilter,
        sweetnessLevel: _sweetnessLevel,
        ecoPackaging: _ecoPackaging,
        onSave: (nutFree, sweetness, eco) {
          setState(() {
            _nutFreeFilter = nutFree;
            _sweetnessLevel = sweetness;
            _ecoPackaging = eco;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bake preferences updated!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _checkout() {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 Order Queued for Fresh Baking!'),
        content: Text(
          'Thank you for ordering with Nyse Bites.\n\n'
          'Tray Total: ${_cart.length} item(s)\n'
          'Amount: ₱${_cartTotal.toStringAsFixed(2)}\n'
          'Sweetness Preference: $_sweetnessLevel\n'
          'Eco Packaging: ${_ecoPackaging ? "Yes" : "Standard"}\n\n'
          'Our kitchen will begin crafting your sweets!',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E4A23),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() => _cart.clear());
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: CartDrawer(
        cartItems: _cart,
        totalPrice: _cartTotal,
        onRemoveItem: _removeFromCart,
        onCheckout: _checkout,
      ),
      appBar: AppBarHeader(
        cartItemCount: _cart.length,
        onOpenCart: () => _scaffoldKey.currentState?.openEndDrawer(),
        onOpenSettings: _openSettings,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroBanner(onExploreMenu: _scrollToMenu),
            _buildMenuSection(),
            // Auto-sliding review carousel component
            const ReviewsSlideshow(),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Text(
            'Explore Our Oven Creations',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E1B10),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Handcrafted fresh daily • Click "Build" on cakes to customize layers & piping!',
            style: TextStyle(color: Color(0xFF756256)),
          ),
          const SizedBox(height: 20),

          // Search Bar
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search cookies, fudge brownies, cakes...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8E4A23)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFEFE4D6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFEFE4D6)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Pills
          CategoryFilter(
            selectedCategory: _selectedCategory,
            onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 28),

          // Product Grid
          if (_filteredProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: const Text(
                'No delicious treats match your search or allergen settings.',
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 340,
                childAspectRatio: 0.74,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductCard(
                  product: product,
                  onAddToCart: _addToCart,
                  onCustomize: _openCustomCakeBuilder,
                );
              },
            ),
        ],
      ),
    );
  }
}