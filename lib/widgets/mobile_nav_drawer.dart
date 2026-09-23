import 'dart:typed_data'; // Add this for Uint8List support
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MobileNavDrawer extends StatelessWidget {
  final VoidCallback onMenuClick;
  final VoidCallback onCustomCakesClick;
  final VoidCallback onDailyBatchesClick;
  final VoidCallback onReviewsClick;
  final VoidCallback onLogoClick;
  final VoidCallback onOurStoryClick;
  final VoidCallback onGalleryClick;
  final VoidCallback? onSweetNoteClick;
  final VoidCallback onContactClick;
  final VoidCallback onOpenAuth;
  final String? currentUser;
  final Uint8List? profileImageBytes; // Added parameter for real-time image bytes
  final VoidCallback onLogout;
  final VoidCallback? onProfileClick;

  const MobileNavDrawer({
    super.key,
    required this.onMenuClick,
    required this.onCustomCakesClick,
    required this.onDailyBatchesClick,
    required this.onReviewsClick,
    required this.onLogoClick,
    required this.onOurStoryClick,
    required this.onGalleryClick,
    this.onSweetNoteClick,
    required this.onContactClick,
    required this.onOpenAuth,
    this.currentUser,
    this.profileImageBytes, // Include in constructor
    required this.onLogout,
    this.onProfileClick,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.brandRed, // Warmer beige background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)), // Rounded right edge
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Drawer Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.bgPastelPink, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.bgPastelPink,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.bgPastelPink, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(60, 34, 22, 0.08),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/nysebites_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.cookie, color: AppColors.textDarkBerry),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NYSE BITES.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkGarnet,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'FRESH ARTISANAL BAKES',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.textDarkBerry,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Navigation Links List ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                                children: [
                  _drawerItem(
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      onLogoClick();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.cookie_outlined,
                    title: 'Menu',
                    onTap: () {
                      Navigator.pop(context);
                      onMenuClick();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.history_edu_rounded,
                    title: 'Our Story',
                    onTap: () {
                      Navigator.pop(context);
                      onOurStoryClick();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.collections_outlined,
                    title: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      onGalleryClick();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.storefront_outlined,
                    title: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                      onContactClick();
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom User Account Card ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.bgPastelPink,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(28),
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(60, 34, 22, 0.04),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: currentUser != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                onProfileClick?.call();
                              },
                              borderRadius: BorderRadius.circular(14),
                              hoverColor: AppColors.bgPastelPink,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    // Updated Avatar with Real-time Image Support
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: const BoxDecoration(
                                        color: AppColors.textDarkBerry,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: profileImageBytes != null
                                            ? Image.memory(
                                                profileImageBytes!,
                                                fit: BoxFit.cover,
                                              )
                                            : Center(
                                                child: Text(
                                                  currentUser!.isNotEmpty
                                                      ? currentUser![0].toUpperCase()
                                                      : 'R',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentUser!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14.5,
                                              color: AppColors.darkGarnet,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Logged In • View Profile',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDarkBerry,
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
                        const SizedBox(width: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgPastelPink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: AppColors.brandRed,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onLogout();
                            },
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.textDarkBerry.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onOpenAuth();
                        },
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: const Text(
                          'Sign In / Join',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Styled Drawer Item ──
  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16), // Smooth highlight borders
          hoverColor: AppColors.bgPastelPink,
          highlightColor: AppColors.bgPastelPink.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandRed, // Cute boxed icons!
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.textDarkBerry, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.darkGarnet,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.bgPastelPink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


