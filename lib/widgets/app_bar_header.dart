import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBarHeader extends StatefulWidget implements PreferredSizeWidget {
  final String? currentUser;
  final bool isAuthChecking;
  final Uint8List? profileImageBytes;
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenAuth;
  final VoidCallback onLogout;
  final VoidCallback onProfileClick;
  final VoidCallback onLogoClick;
  final VoidCallback onMenuClick;
  final VoidCallback onOurStoryClick;
  final VoidCallback onGalleryClick;
  final VoidCallback onContactClick;
  final VoidCallback? onCustomCakesClick;
  final VoidCallback? onDailyBatchesClick;
  final VoidCallback? onReviewsClick;
  final VoidCallback? onSweetNoteClick;
  final VoidCallback? onTrackOrderClick;
  final bool hasActiveOrder;

  final VoidCallback? onSearchClick;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onCartClick;
  final int cartItemCount;

  const AppBarHeader({
    super.key,
    this.currentUser,
    this.isAuthChecking = false,
    this.profileImageBytes,
    required this.onOpenDrawer,
    required this.onOpenAuth,
    required this.onLogout,
    required this.onProfileClick,
    required this.onLogoClick,
    required this.onMenuClick,
    required this.onOurStoryClick,
    required this.onGalleryClick,
    required this.onContactClick,
    this.onCustomCakesClick,
    this.onDailyBatchesClick,
    this.onReviewsClick,
    this.onSweetNoteClick,
    this.onTrackOrderClick,
    this.hasActiveOrder = false,
    this.onSearchClick,
    this.searchController,
    this.onSearchChanged,
    this.onCartClick,
    this.cartItemCount = 0,
  });

  @override
  State<AppBarHeader> createState() => _AppBarHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _AppBarHeaderState extends State<AppBarHeader> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isSearchExpanded = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    setState(() {
      _isSearchExpanded = false;
      widget.searchController?.clear();
      if (widget.onSearchChanged != null) widget.onSearchChanged!('');
      _searchFocusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0E5D8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Row(
            children: [
              // Left Area: Logo & Brand Name
              if (!(isMobile && _isSearchExpanded))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMobile)
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: AppColors.textDarkBerry),
                        onPressed: widget.onOpenDrawer,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (isMobile) const SizedBox(width: 8),
                    InkWell(
                      onTap: widget.onLogoClick,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/nysebites_logo.png',
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.cookie,
                                  color: AppColors.accentGold,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (!isMobile)
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Nyse ',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFB52424), // Brighter red to match logo circle
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Bites',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDarkBerry, // Second tone
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(width: 16),

              // Right Area: AnimatedCrossFade between Nav/Icons and SearchBar
              Expanded(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _isSearchExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerRight,
                      children: [
                        Positioned(
                          key: bottomKey,
                          right: 0,
                          left: 0,
                          child: bottomChild,
                        ),
                        Positioned(
                          key: topKey,
                          right: 0,
                          left: 0,
                          child: topChild,
                        ),
                      ],
                    );
                  },
                  firstChild: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Center Navigation (only on desktop)
                      if (!isMobile) ...[
                        const Spacer(),
                        _navLink('Home', widget.onLogoClick),
                        _navLink('Menu', widget.onMenuClick),
                        _navLink('Our Story', widget.onOurStoryClick),
                        _navLink('Gallery', widget.onGalleryClick),
                        _navLink('Contact', widget.onContactClick),
                        const Spacer(),
                      ],
                      
                      // Right Icons
                      if (widget.searchController != null)
                        IconButton(
                          icon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textDarkBerry,
                          ),
                          onPressed: () {
                            setState(() => _isSearchExpanded = true);
                            Future.delayed(const Duration(milliseconds: 50), () {
                              _searchFocusNode.requestFocus();
                            });
                          },
                        ),
                      const SizedBox(width: 4),

                      // Cart Icon with Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.textDarkBerry,
                            ),
                            onPressed: widget.onCartClick ?? () {},
                          ),
                          if (widget.cartItemCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.accentGold,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Center(
                                  child: Text(
                                    '${widget.cartItemCount}',
                                    style: const TextStyle(
                                      color: AppColors.textDarkBerry,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Track Order pill — only when active order exists
                      if (widget.hasActiveOrder && widget.onTrackOrderClick != null) ...[
                        const SizedBox(width: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.local_shipping_outlined,
                                color: AppColors.textDarkBerry,
                              ),
                              onPressed: widget.onTrackOrderClick,
                              tooltip: 'Track Order',
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.brandRed,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: const Center(
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(width: 8),

                      // Profile / Auth
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: widget.isAuthChecking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textDarkBerry,
                                ),
                              )
                            : (widget.currentUser != null)
                            ? InkWell(
                                onTap: widget.onProfileClick,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.bgPastelPink,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: widget.profileImageBytes != null
                                        ? Image.memory(
                                            widget.profileImageBytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: AppColors.textDarkBerry,
                                            child: Center(
                                              child: Text(
                                                widget.currentUser!.isNotEmpty
                                                    ? widget.currentUser![0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.textDarkBerry,
                                ),
                                onPressed: widget.onOpenAuth,
                              ),
                      ),
                    ],
                  ),
                  secondChild: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2724).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(22),
                              ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search_rounded, color: AppColors.textDarkBerry, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: widget.searchController,
                                focusNode: _searchFocusNode,
                                onChanged: widget.onSearchChanged,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDarkBerry,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search menu, orders, or pages...',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDarkBerry,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textDarkBerry, size: 20),
                              onPressed: _closeSearch,
                              tooltip: 'Close search',
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ))),
                  ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textDarkBerry,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
