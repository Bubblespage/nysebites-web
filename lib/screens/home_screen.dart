import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
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
import '../widgets/customer_profile_modal.dart';
import '../widgets/reviews_slideshow.dart';
import '../widgets/order_tracker_modal.dart';
import '../widgets/oven_gallery_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _sweetNoteKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  String _selectedCategory = 'all';
  String _searchQuery = '';
  final List<Product> _cart = [];
  String? _activeOrderNumber;
  int _activeOrderItemCount = 0;
  double _activeOrderTotal = 0;
  DateTime? _activeOrderPlacedAt;

  String? _currentUser;
  String? _currentUserPhone;
  String? _currentUserAddress;
  StreamSubscription<User?>? _authSubscription;
  bool _isAuthChecking = true;
  String? _lastAddedItemName;
  Timer? _lastAddedTimer;
  Set<String> _favorites = {};

  // ── FIX: Declared here inside _HomeScreenState so it tracks profile picture updates ──
  Uint8List? _globalProfileBytes;

  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _settingsStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _productsStream;

  static const Map<String, int> _productOrderMap = {
    'Biscoff Nocciola Swirl': 1,
    'Snicker-Doodle Hug': 2,
    'Dark Chocolate Noir': 3,
    'Red Velvet Kiss Blossom': 4,
    'Belgian Choco Chip': 5,
    "Hershey's Almond Cloud Squares": 6,
    'Dark Kissed Melt Bites': 7,
    'Pure Decadence Cocoa Fudge': 8,
    'Vanilla Sky Cerulean Dream': 9,
    'Lavender Noir Velvet': 10,
  };

  static int _countItemsFromOrderData(Map<String, dynamic> data) {
    final direct = (data['itemCount'] as num?)?.toInt() ?? 0;
    if (direct > 0) return direct;

    if (data['items'] is List) return (data['items'] as List).length;
    if (data['cart'] is List) return (data['cart'] as List).length;

    int count = 0;
    final itemSummary = (data['item'] ?? '').toString();
    for (final part in itemSummary.split(',')) {
      final match = RegExp(r'^\s*(\d+)x').firstMatch(part);
      if (match != null) {
        count += int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    return count > 0 ? count : 1;
  }

  static bool _isOrderDone(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().toLowerCase();
    final label = (data['statusLabel'] ?? '').toString().toLowerCase();
    return status.contains('complet') ||
        status.contains('reject') ||
        status.contains('cancel') ||
        status.contains('declin') ||
        status == 'delivered' ||
        label.contains('complet') ||
        label.contains('reject') ||
        label.contains('declin') ||
        label.contains('cancel');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen for Web Push Notifications while the app is actively open!
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (!mounted) return;
        _showTopNotification(message);
      }
    });

    _settingsStream = FirebaseFirestore.instance.collection('settings').doc('storefront').snapshots();
    _productsStream = FirebaseFirestore.instance.collection('products').snapshots();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;

      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!mounted) return;

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            final rawRole = (data['role'] ?? '').toString();

            if (rawRole.isNotEmpty &&
                [
                  'super_admin',
                  'Super Admin',
                  'order_dispatcher',
                  'rider',
                  'baker_admin',
                  'Baker Admin',
                ].contains(rawRole)) {
              setState(() {
                _currentUser = null;
                _isAuthChecking = false;
                _favorites.clear();
                _activeOrderNumber = null;
              });
              return;
            }

            final List<dynamic> rawFavorites = data['favorites'] ?? [];
            final Set<String> userFavorites =
                rawFavorites.map((e) => e.toString()).toSet();

            final photoBase64 = data['photoBase64'] as String?;
            Uint8List? profileBytes;
            if (photoBase64 != null && photoBase64.isNotEmpty) {
              try {
                profileBytes = base64Decode(photoBase64);
              } catch (e) {
                debugPrint('Error decoding profile image: $e');
              }
            }

            setState(() {
              _currentUser =
                  data['name'] ?? user.email?.split('@').first ?? 'Guest';
              _currentUserPhone = data['phone'] ?? '';
              _currentUserAddress = data['address'] ?? '';
              _favorites = userFavorites;
              _globalProfileBytes = profileBytes;
              _isAuthChecking = false;
            });
            _fetchActiveOrder(user.uid);
          } else {
            setState(() {
              _currentUser = user.email?.split('@').first ?? 'Guest';
              _currentUserPhone = '';
              _currentUserAddress = '';
              _favorites.clear();
              _globalProfileBytes = null;
              _isAuthChecking = false;
            });
            _fetchActiveOrder(user.uid);
          }
        } catch (e) {
          debugPrint('Error fetching user data: $e');
          if (mounted) setState(() => _isAuthChecking = false);
        }
      } else {
        final needsUpdate = _currentUser != null ||
            _isAuthChecking != false ||
            _favorites.isNotEmpty ||
            _activeOrderNumber != null ||
            _currentUserPhone != null ||
            _currentUserAddress != null ||
            _globalProfileBytes != null;

        if (needsUpdate) {
          setState(() {
            _currentUser = null;
            _currentUserPhone = null;
            _currentUserAddress = null;
            _globalProfileBytes = null;
            _isAuthChecking = false;
            _favorites.clear();
            _activeOrderNumber = null;
          });
        } else if (_isAuthChecking) {
          setState(() => _isAuthChecking = false);
        }
      }
    });
  }

  Future<void> _fetchActiveOrder(String uid) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .limit(20)
          .get();

      if (!mounted) return;

      final activeDocs =
          snap.docs.where((d) => !_isOrderDone(d.data())).toList();

      if (activeDocs.isEmpty) {
        setState(() => _activeOrderNumber = null);
        return;
      }

      activeDocs.sort((a, b) {
        final aRaw = a.data()['createdAt'];
        final bRaw = b.data()['createdAt'];
        final aTime = aRaw is Timestamp ? aRaw.toDate() : DateTime.now();
        final bTime = bRaw is Timestamp ? bRaw.toDate() : DateTime.now();
        return bTime.compareTo(aTime);
      });

      final data = activeDocs.first.data();
      final String orderNumber =
          (data['orderNumber'] ?? data['id'] ?? activeDocs.first.id).toString();

      final String totalStr = (data['total'] ?? '').toString();
      final double totalAmount =
          double.tryParse(totalStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

      DateTime placedAt = DateTime.now();
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        placedAt = createdAt.toDate();
      }

      if (!mounted) return;
      setState(() {
        _activeOrderNumber = orderNumber;
        _activeOrderItemCount = _countItemsFromOrderData(data);
        _activeOrderTotal = totalAmount;
        _activeOrderPlacedAt = placedAt;
      });
    } catch (e, stack) {
      debugPrint('Error fetching active order: $e\n$stack');
    }
  }

  void _showTopNotification(RemoteMessage message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.0,
        left: 0,
        right: 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -80 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3C2216),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFBEBE4).withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3C2216).withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEBE4).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Color(0xFFFBEBE4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.notification!.title ?? 'Nyse Bites Update',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 14.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            message.notification!.body ?? '',
                            style: TextStyle(
                              color: const Color(0xFFFBEBE4).withOpacity(0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        'App resumed from background: Re-syncing Firestore connection streams and refreshing UI.',
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _fetchActiveOrder(user.uid);
      }
    }
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

  void _onGalleryClick() {
    _scrollToKey(_galleryKey, alignment: 0.0);
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

  void _openCustomerProfileModal(bool acceptCustomCakes) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Profile',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: CustomerProfileModal(
            favorites: _favorites,
            onAddToCart: _addToCart,
            onLogout: _logout,
            onToggleFavorite: _toggleFavorite,
            onCustomize: _openCustomCakeBuilder,
            acceptCustomCakes: acceptCustomCakes,
            onOpenCart: () => _scaffoldKey.currentState?.openEndDrawer(),
            currentName: _currentUser ?? '',
            currentPhone: _currentUserPhone ?? '',
            currentAddress: _currentUserAddress ?? '',
            initialImageBytes: _globalProfileBytes,
            onImageUpdated: (newBytes) {
              setState(() {
                _globalProfileBytes = newBytes;
              });
            },
            onProfileUpdated: (name, phone, address) {
              if (mounted) {
                setState(() {
                  _currentUser = name;
                  _currentUserPhone = phone;
                  _currentUserAddress = address;
                });
              }
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null;
      _currentUserPhone = null;
      _currentUserAddress = null;
      _globalProfileBytes = null;
      _favorites.clear();
      _activeOrderNumber = null;
    });
  }

  Future<void> _toggleFavorite(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _openAuthModal();
      return;
    }

    final prodId = product.id.toString();
    final isFav = _favorites.contains(prodId);

    setState(() {
      if (isFav) {
        _favorites.remove(prodId);
      } else {
        _favorites.add(prodId);
      }
    });

    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'name': user.email?.split('@').first ?? 'Guest',
          'email': user.email ?? '',
          'favorites': [if (!isFav) prodId],
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'favorites': isFav
              ? FieldValue.arrayRemove([prodId])
              : FieldValue.arrayUnion([prodId]),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error updating favorites: $e');
      if (mounted) {
        setState(() {
          if (isFav) {
            _favorites.add(prodId);
          } else {
            _favorites.remove(prodId);
          }
        });
      }
    }
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
      _lastAddedItemName = product.name;
    });

    _lastAddedTimer?.cancel();
    _lastAddedTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _lastAddedItemName = null);
    });
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

  void _savePlacedOrder(String orderId, int itemCount, double totalAmount) async {
    setState(() {
      _activeOrderNumber = orderId;
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

  void _openCustomCakeBuilder(Product cakeProduct, bool acceptCustomCakes) {
    if (!acceptCustomCakes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF251811),
          content: Text(
            'Custom cake commissions are currently paused by the bakery.',
          ),
        ),
      );
      return;
    }

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

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _settingsStream,
      builder: (context, settingsSnapshot) {
        final settingsData = settingsSnapshot.data?.data() ?? {};

        final bool isStoreOpen = settingsData['isStoreOpen'] ?? true;
        final bool acceptCustomCakes =
            settingsData['acceptCustomCakes'] ?? true;

        final String announcement1 =
            settingsData['announcement1']?.toString() ??
                settingsData['announcementText']?.toString() ??
                '';
        final String announcement2 =
            settingsData['announcement2']?.toString() ?? '';
        final String announcement3 =
            settingsData['announcement3']?.toString() ??
                '🎂 Custom cakes require a 2-week reservation notice in advance!';

        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFFAF4ED),
          drawer: MobileNavDrawer(
            currentUser: _currentUser,
            profileImageBytes: _globalProfileBytes,
            onProfileClick: () => _openCustomerProfileModal(acceptCustomCakes),
            onMenuClick: _onMenuClick,
            onCustomCakesClick: _onCustomCakesClick,
            onDailyBatchesClick: _onDailyBatchesClick,
            onReviewsClick: _onReviewsClick,
            onGalleryClick: _onGalleryClick,
            onSweetNoteClick: _onSweetNoteClick,
            onContactClick: _onContactClick,
            onOpenAuth: _openAuthModal,
            onLogout: _logout,
          ),
          endDrawer: CartDrawer(
            cartItems: _cart,
            totalPrice: _cartTotal,
            currentUser: _currentUser,
            currentPhone: _currentUserPhone,
            currentAddress: _currentUserAddress,
            onAddToCart: _addToCart,
            onRemoveSingleItem: _removeSingleItem,
            onRemoveAllOfProduct: _removeAllOfProduct,
            onClearCart: _clearCart,
            onOrderPlaced: (orderId, itemCount, totalAmount) {
              _savePlacedOrder(orderId, itemCount, totalAmount);
            },
          ),
          appBar: AppBarHeader(
            currentUser: _currentUser,
            profileImageBytes: _globalProfileBytes,
            isAuthChecking: _isAuthChecking,
            onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            onOpenAuth: _openAuthModal,
            onLogout: _logout,
            onProfileClick: () => _openCustomerProfileModal(acceptCustomCakes),
            onLogoClick: _scrollToTop,
            onMenuClick: _onMenuClick,
            onCustomCakesClick: _onCustomCakesClick,
            onDailyBatchesClick: _onDailyBatchesClick,
            onReviewsClick: _onReviewsClick,
            onGalleryClick: _onGalleryClick,
            onSweetNoteClick: _onSweetNoteClick,
            onContactClick: _onContactClick,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _buildFloatingActions(),
          body: Container(
            color: const Color(0xFFEFE2D2),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Container(
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
                  Container(
                    width: double.infinity,
                    height: 36,
                    color: const Color(0xFF251811),
                    alignment: Alignment.center,
                    child: _MarqueeTicker(
                      announcement1: announcement1,
                      announcement2: announcement2,
                      announcement3: announcement3,
                      velocity: 38.0,
                    ),
                  ),
                  if (!isStoreOpen)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: const Color(0xFFD32F2F),
                      child: const Center(
                        child: Text(
                          '⚠️ Online order checkout is temporarily paused by the kitchen admin.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  HeroBanner(
                    key: _heroKey,
                    onExploreMenu: _onMenuClick,
                    onBuildCustomCake: _onCustomCakesClick,
                  ),
                  _buildMenuSection(isMobile, acceptCustomCakes),

                  SizedBox(height: isMobile ? 48 : 80),

                  Container(
                    key: _reviewsKey,
                    alignment: Alignment.center,
                    child: const ReviewsSlideshow(),
                  ),

                  OvenGallerySection(key: _galleryKey),
                  ContactSection(key: _sweetNoteKey),
                  Footer(key: _footerKey),
                ],
              ),       // Column
            ),         // SingleChildScrollView
          ),           // inner Container (gradient)
              ),       // ConstrainedBox
            ),         // Center
          ),           // outer Container (bg color)
        );
      },
    );
  }

  Widget _buildIconOnlyFloatingTrayButton() {
    final hasItems = _cart.isNotEmpty;
    final isGlowing = _lastAddedItemName != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 12),
      child: AnimatedScale(
        scale: isGlowing ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            borderRadius: BorderRadius.circular(28),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF2E1B10),
                shape: BoxShape.circle,
                border: Border.all(
                    color: isGlowing
                        ? const Color(0xFFF2E3C6)
                        : const Color(0xFFDCC8B8),
                    width: isGlowing ? 3.0 : 1.2),
                boxShadow: isGlowing
                    ? const [
                        BoxShadow(
                          color: Color.fromRGBO(212, 163, 115, 0.85),
                          blurRadius: 28,
                          spreadRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ]
                    : const [
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
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _lastAddedItemName != null
              ? Padding(
                  key: ValueKey(_lastAddedItemName),
                  padding: const EdgeInsets.only(bottom: 12, right: 12),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C2216),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded,
                            color: Color(0xFFF2E3C6), size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '+1 $_lastAddedItemName',
                            style: const TextStyle(
                              color: Color(0xFFF2E3C6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
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

  Widget _buildMenuSection(bool isMobile, bool acceptCustomCakes) {
    return Container(
      key: _menuKey,
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 8 : 10,
      ),
      child: Column(
        children: [
          Text(
            _selectedCategory == 'daily_batches'
                ? "Today's Daily Oven Drops"
                : 'Our Sweet Menu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1B10),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedCategory == 'daily_batches'
                ? 'Small-batch cookies and fudge brownies baked fresh this morning.'
                : 'Handcrafted fresh daily • Click "Build" on cakes to customize layers & piping!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF756256), fontSize: 13),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 10),
          CategoryFilter(
            selectedCategory: _selectedCategory == 'daily_batches'
                ? 'all'
                : _selectedCategory,
            onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _productsStream,
            builder: (context, snapshot) {
              List<Product> rawList = [];

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                rawList = snapshot.data!.docs
                    .map((doc) => Product.fromMap(doc.id, doc.data()))
                    .toList();
              } else {
                rawList = List.from(mockProducts);
              }

              rawList.sort((a, b) {
                final int orderA = _productOrderMap[a.name] ?? a.order;
                final int orderB = _productOrderMap[b.name] ?? b.order;
                return orderA.compareTo(orderB);
              });

              final List<Product> products = rawList.where((Product p) {
                bool matchesCategory;
                final cat = p.category.toLowerCase();
                if (_selectedCategory == 'daily_batches') {
                  matchesCategory = cat == 'cookies' || cat == 'brownies';
                } else if (_selectedCategory == 'all') {
                  matchesCategory = true;
                } else {
                  matchesCategory = cat == _selectedCategory.toLowerCase();
                }

                final matchesSearch = p.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    p.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());

                return matchesCategory && matchesSearch && p.active;
              }).toList();

              if (products.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: const Text(
                    'No delicious treats match your search or allergen settings.',
                    style: TextStyle(color: Color(0xFF756256)),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;

                  final columnCount = availableWidth <= 550
                      ? 2
                      : availableWidth <= 850
                          ? 3
                          : 4;

                  final spacing = availableWidth < 760 ? 12.0 : 20.0;
                  final cardWidth =
                      (availableWidth - (columnCount - 1) * spacing) /
                          columnCount;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnCount,
                      mainAxisExtent: ProductCard.computeHeight(cardWidth),
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        key: ValueKey(product.name),
                        product: product,
                        cardWidth: cardWidth,
                        isFavorite: _currentUser != null &&
                            _favorites.contains(product.id.toString()),
                        onFavoriteToggle: () => _toggleFavorite(product),
                        onAddToCart: _addToCart,
                        onCustomize: (prod) =>
                            _openCustomCakeBuilder(prod, acceptCustomCakes),
                      );
                    },
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

class _MarqueeTicker extends StatefulWidget {
  final String announcement1;
  final String announcement2;
  final String announcement3;
  final TextStyle? style;
  final double velocity;

  const _MarqueeTicker({
    required this.announcement1,
    required this.announcement2,
    required this.announcement3,
    this.style,
    this.velocity = 38.0,
  });

  @override
  State<_MarqueeTicker> createState() => _MarqueeTickerState();
}

class _MarqueeTickerState extends State<_MarqueeTicker> {
  late final ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoop());
  }

  void _startLoop() async {
    if (!mounted) return;
    _isScrolling = true;

    await Future.delayed(const Duration(milliseconds: 500));

    while (mounted && _isScrolling) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;

        if (maxScroll > 2.0) {
          final int durationSec = (maxScroll / widget.velocity).clamp(10.0, 60.0).toInt();

          try {
            await _scrollController.animateTo(
              maxScroll,
              duration: Duration(seconds: durationSec),
              curve: Curves.linear,
            );
          } catch (_) {}

          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(0.0);
          }
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tickerItems = [];
    if (widget.announcement1.isNotEmpty) {
      tickerItems.add({
        'icon': '✨',
        'title': 'STORE NOTICE',
        'body': widget.announcement1,
      });
    }
    if (widget.announcement2.isNotEmpty) {
      tickerItems.add({
        'icon': '🥐',
        'title': 'DAILY OVEN DROP',
        'body': widget.announcement2,
      });
    }
    if (widget.announcement3.isNotEmpty) {
      tickerItems.add({
        'icon': '🎂',
        'title': 'SPECIAL NOTICE',
        'body': widget.announcement3,
      });
    }

    if (tickerItems.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tickerItems.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E4A23),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 5),
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item['body']!,
                style: widget.style ??
                    const TextStyle(
                      color: Color(0xFFFAFAFA),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(width: 24),
              const Text(
                '✦',
                style: TextStyle(color: Color(0xFFC89269), fontSize: 11),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}