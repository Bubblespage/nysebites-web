import 'package:flutter/material.dart';
import '../data/mock_products.dart';
import '../models/product.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/auth_modal.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/category_filter.dart';
import '../widgets/contact_section.dart';
import '../widgets/custom_cake_modal.dart';
import '../widgets/footer.dart';
import '../widgets/hero_banner.dart';
import '../widgets/mobile_nav_drawer.dart';
import '../widgets/product_card.dart';
import '../widgets/reviews_slideshow.dart';
import '../widgets/order_tracker_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _sweetNoteKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  String _selectedCategory = 'all';
  String _searchQuery = '';
  final List<Product> _cart = [];
  String? _activeOrderNumber;
  int _activeOrderItemCount = 0;
  double _activeOrderTotal = 0;
  DateTime? _activeOrderPlacedAt;

  // Auth User State
  String? _currentUser;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return mockProducts.where((p) {
      bool matchesCategory;
      if (_selectedCategory == 'daily_batches') {
        matchesCategory = p.category == 'cookies' || p.category == 'brownies';
      } else if (_selectedCategory == 'all') {
        matchesCategory = true;
      } else {
        matchesCategory = p.category == _selectedCategory;
      }

      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get _cartTotal => _cart.fold(0.0, (sum, item) => sum + item.price);

  void _scrollToKey(GlobalKey key, {double alignment = 0.0}) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: alignment,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onMenuClick() {
    setState(() => _selectedCategory = 'all');
    _scrollToKey(_menuKey);
  }

  void _onCustomCakesClick() {
    setState(() => _selectedCategory = 'cakes');
    _scrollToKey(_menuKey);
  }

  void _onDailyBatchesClick() {
    setState(() => _selectedCategory = 'daily_batches');
    _scrollToKey(_menuKey);
  }

  void _onReviewsClick() {
    _scrollToKey(_reviewsKey, alignment: 0.0);
  }

  void _onSweetNoteClick() {
    _scrollToKey(_sweetNoteKey, alignment: 0.0);
  }

  void _onContactClick() {
    _scrollToKey(_footerKey, alignment: 0.0);
  }

  void _openAuthModal() {
    showDialog(
      context: context,
      builder: (context) => AuthModal(
        onLoginSuccess: (userName) {
          setState(() => _currentUser = userName);
        },
      ),
    );
  }

  void _logout() {
    setState(() => _currentUser = null);
  }

  void _addToCart(Product product) {
    setState(() => _cart.add(product));
  }

  void _removeSingleItem(Product product) {
    final index = _cart.indexWhere(
      (p) =>
          p.id == product.id &&
          p.price == product.price &&
          p.name == product.name,
    );
    if (index != -1) {
      setState(() => _cart.removeAt(index));
    }
  }

  void _removeAllOfProduct(Product product) {
    setState(() {
      _cart.removeWhere(
        (p) =>
            p.id == product.id &&
            p.price == product.price &&
            p.name == product.name,
      );
    });
  }

  void _clearCart() {
    setState(() => _cart.clear());
  }

  void _savePlacedOrder(int itemCount, double totalAmount) {
    setState(() {
      _activeOrderNumber =
          'NB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      _activeOrderItemCount = itemCount;
      _activeOrderTotal = totalAmount;
      _activeOrderPlacedAt = DateTime.now();
    });
  }

  void _openOrderTracker() {
    final placedAt = _activeOrderPlacedAt;
    final orderNumber = _activeOrderNumber;
    if (placedAt == null || orderNumber == null) return;

    showDialog(
      context: context,
      builder: (context) => OrderTrackerModal(
        orderNumber: orderNumber,
        itemCount: _activeOrderItemCount,
        totalAmount: _activeOrderTotal,
        placedAt: placedAt,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAF4ED),
      // Left Mobile Navigation Drawer
      drawer: MobileNavDrawer(
        currentUser: _currentUser,
        onMenuClick: _onMenuClick,
        onCustomCakesClick: _onCustomCakesClick,
        onDailyBatchesClick: _onDailyBatchesClick,
        onReviewsClick: _onReviewsClick,
        onSweetNoteClick: _onSweetNoteClick,
        onContactClick: _onContactClick,
        onOpenAuth: _openAuthModal,
        onLogout: _logout,
      ),
      // Right Sweet Tray Drawer
      endDrawer: CartDrawer(
        cartItems: _cart,
        totalPrice: _cartTotal,
        currentUser: _currentUser,
        onAddToCart: _addToCart,
        onRemoveSingleItem: _removeSingleItem,
        onRemoveAllOfProduct: _removeAllOfProduct,
        onClearCart: _clearCart,
        onOrderPlaced: _savePlacedOrder,
      ),
      appBar: AppBarHeader(
        currentUser: _currentUser,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        onOpenAuth: _openAuthModal,
        onLogout: _logout,
        onLogoClick: _scrollToTop,
        onMenuClick: _onMenuClick,
        onCustomCakesClick: _onCustomCakesClick,
        onDailyBatchesClick: _onDailyBatchesClick,
        onReviewsClick: _onReviewsClick,
        onSweetNoteClick: _onSweetNoteClick,
        onContactClick: _onContactClick,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActions(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.25, 0.55, 0.85, 1.0],
            colors: [
              Color(0xFFFAF2E9),
              Color(0xFFFBF6F0),
              Color(0xFFF8EFE4),
              Color(0xFFF5E9DB),
              Color(0xFFEFE2D2),
            ],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              HeroBanner(
                key: _heroKey,
                onExploreMenu: _onMenuClick,
                onBuildCustomCake: _onCustomCakesClick,
              ),
              _buildMenuSection(isMobile),

              // Reviews Section
              Container(
                key: _reviewsKey,
                constraints: BoxConstraints(
                  minHeight: isMobile
                      ? 0
                      : MediaQuery.of(context).size.height * 0.7,
                ),
                alignment: Alignment.center,
                child: const ReviewsSlideshow(),
              ),

              // Sweet Note Section
              ContactSection(key: _sweetNoteKey),

              // Footer Section
              Footer(key: _footerKey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconOnlyFloatingTrayButton() {
    final hasItems = _cart.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2E1B10),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDCC8B8), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.28),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                if (hasItems)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E4A23),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${_cart.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_activeOrderNumber != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 12),
            child: ElevatedButton.icon(
              onPressed: _openOrderTracker,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAF2E9),
                foregroundColor: const Color(0xFF8E4A23),
                elevation: 4,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(color: Color(0xFFE5D5C5)),
                ),
              ),
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text(
                'Track Order',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
        _buildIconOnlyFloatingTrayButton(),
      ],
    );
  }

  Widget _buildMenuSection(bool isMobile) {
    return Container(
      key: _menuKey,
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 32 : 48,
      ),
      child: Column(
        children: [
          Text(
            _selectedCategory == 'daily_batches'
                ? 'Today\'s Daily Oven Drops'
                : 'Explore Our Oven Creations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1B10),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory == 'daily_batches'
                ? 'Small-batch cookies and fudge brownies baked fresh this morning.'
                : 'Handcrafted fresh daily • Click "Build" on cakes to customize layers & piping!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF756256), fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Search Bar
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search cookies, fudge brownies, cakes...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8E4A23)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Color(0xFF8E4A23),
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
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
            selectedCategory: _selectedCategory == 'daily_batches'
                ? 'all'
                : _selectedCategory,
            onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 28),

          if (_filteredProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: const Text(
                'No delicious treats match your search or allergen settings.',
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final columnCount = availableWidth < 900
                    ? 2
                    : availableWidth < 1060
                    ? 3
                    : 4;
                final spacing = availableWidth < 760 ? 12.0 : 20.0;
                final cardWidth =
                    (availableWidth - (columnCount - 1) * spacing) /
                    columnCount;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    childAspectRatio: cardWidth < 220 ? 0.62 : 0.76,
                    mainAxisExtent: availableWidth < 900 ? 310 : null,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: _addToCart,
                      onCustomize: _openCustomCakeBuilder,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
