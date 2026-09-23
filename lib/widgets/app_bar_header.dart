import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
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
  
  // Adding search and cart callbacks for the new layout
  final VoidCallback? onSearchClick;
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
    this.onCartClick,
    this.cartItemCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Area: Logo & Brand Name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMobile)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppColors.textDarkBerry),
                      onPressed: onOpenDrawer,
                    ),
                  InkWell(
                    onTap: onLogoClick,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
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
                        const SizedBox(width: 12),
                        if (!isMobile)
                          const Text(
                            'Nyse Bites',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkBerry,
                              letterSpacing: -0.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Center Navigation
              if (!isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _navLink('Home', onLogoClick),
                    _navLink('Menu', onMenuClick),
                    _navLink('Our Story', onOurStoryClick),
                    _navLink('Gallery', onGalleryClick),
                    _navLink('Contact', onContactClick),
                  ],
                ),

              // Right Icons (Search, Profile, Cart)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMobile) ...[
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: AppColors.textDarkBerry),
                      onPressed: onSearchClick ?? () {},
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Cart Icon with Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDarkBerry),
                        onPressed: onCartClick ?? () {},
                      ),
                      if (cartItemCount > 0)
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
                                '$cartItemCount',
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
                  if (hasActiveOrder && onTrackOrderClick != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onTrackOrderClick,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bgPastelPink,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.textDarkBerry.withValues(alpha: 0.15)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.textDarkBerry),
                            SizedBox(width: 6),
                            Text(
                              'Track Order',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDarkBerry,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(width: 8),

                  // Profile / Auth — rightmost
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isAuthChecking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDarkBerry),
                          )
                        : (currentUser != null)
                            ? InkWell(
                                onTap: onProfileClick,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.bgPastelPink, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: profileImageBytes != null
                                        ? Image.memory(profileImageBytes!, fit: BoxFit.cover)
                                        : Container(
                                            color: AppColors.textDarkBerry,
                                            child: Center(
                                              child: Text(
                                                currentUser!.isNotEmpty ? currentUser![0].toUpperCase() : 'U',
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
                                icon: const Icon(Icons.person_outline_rounded, color: AppColors.textDarkBerry),
                                onPressed: onOpenAuth,
                              ),
                  ),
                ],
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
