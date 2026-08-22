import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tabs/live_orders_tab.dart';
import 'tabs/dashboard_overview_tab.dart';
import 'tabs/custom_cake_desk_tab.dart';
import 'tabs/batch_drops_menu_tab.dart';
import 'tabs/sweet_notes_tab.dart';
import 'tabs/store_settings_tab.dart';
import 'tabs/security_permissions_tab.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String currentRole;
  final String adminEmail;

  const AdminDashboardScreen({
    super.key,
    this.currentRole = 'Super Admin',
    this.adminEmail = 'admin@nysebites.com',
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color creamCanvas = Color(0xFFF5EBE1);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);
  static const Color wellBg = Color(0xFFF4EDE6);

  int _selectedNavIndex = 0;
  String _searchQuery = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    setState(() {
      _selectedNavIndex = index;
      _searchQuery = '';
      _searchController.clear();
    });
    _animController.reset();
    _animController.forward();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Staff Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textDark,
          ),
        ),
        content: Text(
          'Sign out of the ${widget.currentRole} session?',
          style: const TextStyle(fontSize: 12, color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(
    String id,
    String newStatus,
    String newLabel,
  ) async {
    try {
      final docRef = _firestore.collection('orders').doc(id);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        await docRef.update({
          'status': newStatus,
          'statusLabel': newLabel,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final queryById = await _firestore
            .collection('orders')
            .where('id', isEqualTo: id)
            .limit(1)
            .get();

        if (queryById.docs.isNotEmpty) {
          await queryById.docs.first.reference.update({
            'status': newStatus,
            'statusLabel': newLabel,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          final queryByOrderNum = await _firestore
              .collection('orders')
              .where('orderNumber', isEqualTo: id)
              .limit(1)
              .get();

          if (queryByOrderNum.docs.isNotEmpty) {
            await queryByOrderNum.docs.first.reference.update({
              'status': newStatus,
              'statusLabel': newLabel,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkEspresso,
          duration: const Duration(seconds: 2),
          content: Text(
            'Order $id updated: $newLabel',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE57373),
          content: Text('Failed to update status: $e'),
        ),
      );
    }
  }

  Future<void> _adjustProductStock(
    String docId,
    int currentStock,
    int delta,
  ) async {
    final int nextStock = (currentStock + delta).clamp(0, 500).toInt();
    await _firestore.collection('products').doc(docId).update({
      'stock': nextStock,
      'active': nextStock > 0,
    });
  }

  Future<void> _toggleProductStatus(String docId, bool currentStatus) async {
    await _firestore.collection('products').doc(docId).update({
      'active': !currentStatus,
    });
  }

  Future<void> _addNewProduct(Map<String, dynamic> newProd) async {
    await _firestore.collection('products').add({
      ...newProd,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _getSearchPlaceholder() {
    switch (_selectedNavIndex) {
      case 0:
        return 'Search live orders...';
      case 1:
        return 'Search analytics...';
      case 2:
        return 'Search custom cakes...';
      case 3:
        return 'Search menu items...';
      case 4:
        return 'Search sweet notes...';
      case 6:
        return 'Search permissions...';
      default:
        return 'Search admin desk...';
    }
  }

  Widget _buildStreamLoader(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: brandCocoa,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;
        final bool isSmallMobile = constraints.maxWidth < 450;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: creamCanvas,
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: darkEspresso,
                  child: SafeArea(child: _buildSidebar(isDrawer: true)),
                ),
          body: Row(
            children: [
              if (isDesktop)
                SizedBox(width: 250, child: _buildSidebar(isDrawer: false)),
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(
                      isDesktop: isDesktop,
                      isSmallMobile: isSmallMobile,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(
                          isDesktop ? 28 : (isSmallMobile ? 12 : 16),
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: _buildActiveTabContent(isDesktop),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar({required bool isDrawer}) {
    final bool isSuperAdmin = widget.currentRole == 'Super Admin';
    final bool isDispatcher = widget.currentRole == 'Order Dispatcher';

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('orders').snapshots(),
      builder: (context, ordersSnap) {
        final ordersDocs = ordersSnap.data?.docs ?? [];
        final int liveOrdersCount = ordersDocs.length;
        final int pendingCustomCakesCount = ordersDocs.where((d) {
          final data = d.data();
          final status = (data['status'] ?? '').toString().toLowerCase();
          final bool isCustom =
              data['isCustom'] == true ||
              (data['item'] ?? '').toString().toLowerCase().contains('custom') ||
              (data['category'] ?? '').toString().toLowerCase().contains('cake');
          return isCustom &&
              (status == 'pending_spec_review' ||
                  status == 'pending_ewallet' ||
                  status == 'pending_cod' ||
                  status == 'received');
        }).length;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('sweet_notes').snapshots(),
          builder: (context, notesSnap) {
            final notesDocs = notesSnap.data?.docs ?? [];
            final int unreadNotesCount = notesDocs
                .where((d) => d.data()['isRead'] == false)
                .length;

            return Container(
              color: darkEspresso,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 40,
                            color: borderLight,
                            alignment: Alignment.center,
                            child: const Text(
                              '🍪',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NYSE BITES.',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            widget.currentRole.toUpperCase(),
                            style: const TextStyle(
                              color: brandCocoa,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildNavItem(
                    0,
                    '📋 Live Orders',
                    count: '$liveOrdersCount',
                    isDrawer: isDrawer,
                  ),
                  if (!isDispatcher) ...[
                    _buildNavItem(1, '📊 Dashboard', isDrawer: isDrawer),
                    _buildNavItem(
                      2,
                      '🎂 Custom Cake Desk',
                      count: pendingCustomCakesCount > 0
                          ? '$pendingCustomCakesCount'
                          : null,
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      3,
                      '🍪 Batch Drops & Menu',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      4,
                      '✉️ Sweet Notes Inbox',
                      count: unreadNotesCount > 0 ? '$unreadNotesCount' : null,
                      isDrawer: isDrawer,
                    ),
                  ],
                  if (isSuperAdmin)
                    _buildNavItem(
                      5,
                      '⚙️ Storefront Settings',
                      isDrawer: isDrawer,
                    ),
                  if (!isDispatcher)
                    _buildNavItem(
                      6,
                      '🛡️ Security & Roles',
                      isDrawer: isDrawer,
                    ),
                  const Spacer(),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.logout,
                      color: Color(0xFFE57373),
                      size: 18,
                    ),
                    title: const Text(
                      'Logout Session',
                      style: TextStyle(
                        color: Color(0xFFE57373),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      _handleLogout();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    String label, {
    String? count,
    required bool isDrawer,
  }) {
    final bool active = _selectedNavIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: active ? brandCocoa : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFFD9C3B0),
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          trailing: count != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active ? darkEspresso : brandCocoa,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () {
            _switchTab(index);
            if (isDrawer) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isDesktop, required bool isSmallMobile}) {
    return Container(
      height: 65,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderLight)),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: darkEspresso),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: wellBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? brandCocoa
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: _getSearchPlaceholder(),
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: const TextStyle(
                          fontSize: 11.5,
                          color: textMuted,
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: wellBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderLight),
            ),
            child: Text(
              isSmallMobile
                  ? widget.currentRole.split(' ').first
                  : widget.currentRole,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: brandCocoa,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(bool isDesktop) {
    switch (_selectedNavIndex) {
      case 0:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildStreamLoader('Connecting to live order desk...');
            }
            final docs = snapshot.data?.docs ?? [];

            var orders = docs.map((d) => {'docId': d.id, ...d.data()}).where((
              o,
            ) {
              if (_searchQuery.trim().isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return (o['id'] ?? '').toString().toLowerCase().contains(q) ||
                  (o['customer'] ?? '').toString().toLowerCase().contains(q) ||
                  (o['item'] ?? '').toString().toLowerCase().contains(q);
            }).toList();

            orders.sort((a, b) {
              final aTime = a['createdAt'];
              final bTime = b['createdAt'];

              DateTime dateA = DateTime.fromMillisecondsSinceEpoch(0);
              DateTime dateB = DateTime.fromMillisecondsSinceEpoch(0);

              if (aTime is Timestamp) dateA = aTime.toDate();
              if (bTime is Timestamp) dateB = bTime.toDate();

              if (dateA == dateB) {
                final idA =
                    int.tryParse(
                      (a['id'] ?? '').toString().replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      ),
                    ) ??
                    0;
                final idB =
                    int.tryParse(
                      (b['id'] ?? '').toString().replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      ),
                    ) ??
                    0;
                return idB.compareTo(idA);
              }

              return dateB.compareTo(dateA);
            });

            return LiveOrdersTab(
              orders: orders,
              isDesktop: isDesktop,
              searchQuery: _searchQuery,
              currentRole: widget.currentRole,
              onUpdateStatus: _updateOrderStatus,
            );
          },
        );

      case 1:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildStreamLoader(
                'Computing bakery revenue and oven deck load...',
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final orders = docs
                .map((d) => {'docId': d.id, ...d.data()})
                .toList();

            return DashboardOverviewTab(orders: orders);
          },
        );

      case 2:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildStreamLoader(
                'Loading custom cake specifications...',
              );
            }
            final docs = snapshot.data?.docs ?? [];
            final customCakes = docs
                .map((d) => {'docId': d.id, ...d.data()})
                .where((o) {
                  final bool isCustomFlag =
                      o['isCustom'] == true ||
                      o['isCustom']?.toString().toLowerCase() == 'true';
                  final String itemName = (o['item'] ?? o['productName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final String category = (o['category'] ?? '')
                      .toString()
                      .toLowerCase();

                  final bool isCustomCake =
                      isCustomFlag ||
                      itemName.contains('custom') ||
                      itemName.contains('cake') ||
                      category.contains('cake');

                  if (!isCustomCake) return false;

                  if (_searchQuery.trim().isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return (o['id'] ?? '').toString().toLowerCase().contains(q) ||
                      (o['customer'] ?? '').toString().toLowerCase().contains(
                        q,
                      ) ||
                      itemName.contains(q) ||
                      (o['note'] ?? '').toString().toLowerCase().contains(q);
                })
                .toList();

            return CustomCakeDeskTab(
              customCakes: customCakes,
              onUpdateStatus: _updateOrderStatus,
              onRejectSpec: (id) async {
                final docRef = _firestore.collection('orders').doc(id);
                final docSnap = await docRef.get();
                if (docSnap.exists) {
                  await docRef.delete();
                } else {
                  final query = await _firestore
                      .collection('orders')
                      .where('id', isEqualTo: id)
                      .limit(1)
                      .get();
                  if (query.docs.isNotEmpty) {
                    await query.docs.first.reference.delete();
                  }
                }

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: darkEspresso,
                    content: Text(
                      'Custom cake spec for $id rejected and removed.',
                    ),
                  ),
                );
              },
            );
          },
        );

      case 3:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildStreamLoader('Fetching bakery menu inventory...');
            }
            final docs = snapshot.data?.docs ?? [];
            final inventory = docs
                .map((d) => {'docId': d.id, ...d.data()})
                .where((item) {
                  if (_searchQuery.trim().isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return (item['name'] ?? '').toString().toLowerCase().contains(
                        q,
                      ) ||
                      (item['category'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(q);
                })
                .toList();

            return BatchDropsMenuTab(
              inventory: inventory,
              currentRole: widget.currentRole,
              onAddProduct: _addNewProduct,
              onToggleStatus: (index) {
                final item = inventory[index];
                _toggleProductStatus(item['docId'], item['active'] == true);
              },
              onAdjustStock: (index, delta) {
                final item = inventory[index];
                final currentStock = item['stock'] as int? ?? 0;
                _adjustProductStock(item['docId'], currentStock, delta);
              },
            );
          },
        );

      case 4:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('sweet_notes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildStreamLoader('Opening sweet notes inbox...');
            }
            final docs = snapshot.data?.docs ?? [];
            final notes = docs.map((d) => {'docId': d.id, ...d.data()}).where((
              note,
            ) {
              if (_searchQuery.trim().isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return (note['name'] ?? '').toString().toLowerCase().contains(
                    q,
                  ) ||
                  (note['email'] ?? '').toString().toLowerCase().contains(q) ||
                  (note['subject'] ?? '').toString().toLowerCase().contains(
                    q,
                  ) ||
                  (note['message'] ?? '').toString().toLowerCase().contains(q);
            }).toList();

            return SweetNotesTab(sweetNotes: notes);
          },
        );

      case 5:
        return const StoreSettingsTab();

      case 6:
        return SecurityPermissionsTab(
          currentRole: widget.currentRole,
          adminEmail: widget.adminEmail,
        );

      default:
        return const Center(child: Text('Invalid Tab Selected'));
    }
  }
}