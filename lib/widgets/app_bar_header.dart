import 'package:flutter/material.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? currentUser;
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenAuth;
  final VoidCallback onLogout;
  final VoidCallback onLogoClick;
  final VoidCallback onMenuClick;
  final VoidCallback onCustomCakesClick;
  final VoidCallback onDailyBatchesClick;
  final VoidCallback onReviewsClick;
  final VoidCallback onSweetNoteClick;
  final VoidCallback onContactClick;

  const AppBarHeader({
    super.key,
    this.currentUser,
    required this.onOpenDrawer,
    required this.onOpenAuth,
    required this.onLogout,
    required this.onLogoClick,
    required this.onMenuClick,
    required this.onCustomCakesClick,
    required this.onDailyBatchesClick,
    required this.onReviewsClick,
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
        color: Color(0xFFFDFBF7),
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

          // Center Navigation: Shown Only on Desktop
          if (!isMobile)
            Row(
              children: [
                _navLink('Fresh Menu', onMenuClick),
                _navLink('Custom Cakes', onCustomCakesClick),
                _navLink('Daily Batches', onDailyBatchesClick),
                _navLink('Reviews', onReviewsClick),
                _navLink('Sweet Note', onSweetNoteClick),
                _navLink('Contact', onContactClick),
              ],
            ),

          // Right Profile / Auth & Preferences Action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentUser != null)
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'logout') onLogout();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'Signed in as $currentUser',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E1B10),
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: const Color(0xFF8E4A23),
                          child: Text(
                            currentUser![0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
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
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: Color(0xFF756256),
                        ),
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
