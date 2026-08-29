import 'package:flutter/material.dart';

class MobileNavDrawer extends StatelessWidget {
  final VoidCallback onMenuClick;
  final VoidCallback onCustomCakesClick;
  final VoidCallback onDailyBatchesClick;
  final VoidCallback onReviewsClick;
  final VoidCallback onGalleryClick;
  final VoidCallback onSweetNoteClick;
  final VoidCallback onContactClick;
  final VoidCallback onOpenAuth;
  final String? currentUser;
  final VoidCallback onLogout;

  const MobileNavDrawer({
    super.key,
    required this.onMenuClick,
    required this.onCustomCakesClick,
    required this.onDailyBatchesClick,
    required this.onReviewsClick,
    required this.onGalleryClick,
    required this.onSweetNoteClick,
    required this.onContactClick,
    required this.onOpenAuth,
    this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFCF7EF), // Warmer beige background
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
                  bottom: BorderSide(color: Color(0xFFEFE4D6), width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E7DC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
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
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.cookie, color: Color(0xFF8E4A23)),
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
                          color: Color(0xFF2E1B10),
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
                          color: Color(0xFF8E4A23),
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
                    icon: Icons.cookie_outlined, // More thematic icon
                    title: 'Fresh Menu',
                    onTap: () {
                      Navigator.pop(context);
                      onMenuClick();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.cake_outlined,
                    title: 'Custom Cakes',
                    onTap: () {
                      Navigator.pop(context);
                      onCustomCakesClick();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.local_fire_department_outlined,
                    title: 'Daily Batches',
                    onTap: () {
                      Navigator.pop(context);
                      onDailyBatchesClick();
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Divider(color: Color(0xFFEFE4D6), thickness: 1.5, height: 1),
                  ),
                  _drawerItem(
                    icon: Icons.star_outline_rounded,
                    title: 'Customer Reviews',
                    onTap: () {
                      Navigator.pop(context);
                      onReviewsClick();
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
                    icon: Icons.mail_outline_rounded,
                    title: 'Sweet Note',
                    onTap: () {
                      Navigator.pop(context);
                      onSweetNoteClick();
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
                color: Color(0xFFFAFAFA),
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
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF8E4A23),
                          child: Text(
                            currentUser![0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                                  color: Color(0xFF2E1B10),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Logged In',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF756256),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: Color(0xFFDC2626),
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
                          backgroundColor: const Color(0xFF8E4A23),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF8E4A23).withOpacity(0.4),
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
          hoverColor: const Color(0xFFF3E7DC),
          highlightColor: const Color(0xFFEFE4D6).withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EAE0), // Cute boxed icons!
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF8E4A23), size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF2E1B10),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFFDCC8B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}