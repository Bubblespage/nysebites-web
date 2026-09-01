import 'dart:typed_data'; // Add this import for Uint8List
import 'package:flutter/material.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? currentUser;
  final bool isAuthChecking;
  final Uint8List? profileImageBytes; // Added parameter for real-time image bytes
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenAuth;
  final VoidCallback onLogout;
  final VoidCallback onProfileClick;
  final VoidCallback onLogoClick;
  final VoidCallback onMenuClick;
  final VoidCallback onCustomCakesClick;
  final VoidCallback onDailyBatchesClick;
  final VoidCallback onReviewsClick;
  final VoidCallback onGalleryClick;
  final VoidCallback onSweetNoteClick;
  final VoidCallback onContactClick;

  const AppBarHeader({
    super.key,
    this.currentUser,
    this.isAuthChecking = false,
    this.profileImageBytes, // Include in constructor
    required this.onOpenDrawer,
    required this.onOpenAuth,
    required this.onLogout,
    required this.onProfileClick,
    required this.onLogoClick,
    required this.onMenuClick,
    required this.onCustomCakesClick,
    required this.onDailyBatchesClick,
    required this.onReviewsClick,
    required this.onGalleryClick,
    required this.onSweetNoteClick,
    required this.onContactClick,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1180;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(bottom: BorderSide(color: Color(0xFFEFE4D6))),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(60, 34, 22, 0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Area: Hamburger on Mobile + Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMobile)
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFF2E1B10),
                    size: 24,
                  ),
                  onPressed: onOpenDrawer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 38),
                ),
              InkWell(
                onTap: onLogoClick,
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E7DC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5D5C5)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.cookie,
                            color: Color(0xFF8E4A23),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'NYSE ',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E1B10),
                            ),
                            children: [
                              TextSpan(
                                text: 'BITES.',
                                style: TextStyle(color: Color(0xFF8E4A23)),
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile)
                          const Text(
                            'COOKIES • BROWNIES • CUSTOM CAKES',
                            style: TextStyle(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: Color(0xFF756256),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Center Navigation: Shown Only on Desktop (Includes Gallery)
          if (!isMobile)
            Row(
              children: [
                _navLink('Fresh Menu', onMenuClick),
                _navLink('Custom Cakes', onCustomCakesClick),
                _navLink('Daily Batches', onDailyBatchesClick),
                _navLink('Reviews', onReviewsClick),
                _navLink('Gallery', onGalleryClick),
                _navLink('Sweet Note', onSweetNoteClick),
                _navLink('Contact', onContactClick),
              ],
            ),

          // Right Profile / Auth & Preferences Action
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: ValueKey<String>(isAuthChecking ? 'loading' : (currentUser ?? 'guest')),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAuthChecking)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8E4A23)),
                    ),
                  )
                else if (currentUser != null)
                  InkWell(
                    onTap: onProfileClick,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF2E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5D5C5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Updated Avatar Container with Real-time Image Support
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: ClipOval(
                              child: profileImageBytes != null
                                  ? Image.memory(profileImageBytes!, fit: BoxFit.cover)
                                  : Container(
                                      color: const Color(0xFF8E4A23),
                                      child: Center(
                                        child: Text(
                                          currentUser!.isNotEmpty ? currentUser![0].toUpperCase() : 'R',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 6),
                            Text(
                              currentUser!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E1B10),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E1B10),
                      side: const BorderSide(color: Color(0xFFDCC8B8)),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: onOpenAuth,
                    icon: const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: Color(0xFF8E4A23),
                    ),
                    label: Text(
                      isMobile ? 'Sign In' : 'Sign In / Join',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF3C2216),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        child: Text(title),
      ),
    );
  }
}