import 'package:flutter/material.dart';

class MobileNavDrawer extends StatelessWidget {
  final VoidCallback onMenuClick;
  final VoidCallback onCustomCakesClick;
  final VoidCallback onDailyBatchesClick;
  final VoidCallback onReviewsClick;
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
    required this.onSweetNoteClick,
    required this.onContactClick,
    required this.onOpenAuth,
    this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFDFBF7),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEFE4D6))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E7DC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5D5C5)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.cookie, color: Color(0xFF8E4A23)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NYSE BITES.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E1B10),
                        ),
                      ),
                      Text(
                        'FRESH ARTISANAL BAKES',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Color(0xFF756256),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Links List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _drawerItem(
                    icon: Icons.restaurant_menu_rounded,
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
                  _drawerItem(
                    icon: Icons.star_outline_rounded,
                    title: 'Customer Reviews',
                    onTap: () {
                      Navigator.pop(context);
                      onReviewsClick();
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

            // Bottom User Account Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEFE4D6))),
              ),
              child: currentUser != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF8E4A23),
                          child: Text(
                            currentUser![0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: Color(0xFF2E1B10),
                                ),
                              ),
                              const Text(
                                'Logged In',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF756256),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            onLogout();
                          },
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E4A23),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onOpenAuth();
                        },
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: const Text(
                          'Sign In / Join',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8E4A23), size: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          color: Color(0xFF2E1B10),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: Color(0xFF9E8E84),
      ),
      onTap: onTap,
    );
  }
}
