import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback onExploreMenu;

  const HeroBanner({super.key, required this.onExploreMenu});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDF7F0), Color(0xFFF7ECE1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 36 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Promo Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E4A23).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF8E4A23).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('✨ ', style: TextStyle(fontSize: 12)),
                    Text(
                      'BAKED FRESH TO ORDER EVERY MORNING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8E4A23),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Headline
              const Text(
                'Warm, Chewy, & Irresistibly Fudgy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E1B10),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),

              // Subheading
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: const Text(
                  'Serving freshly brewed coffee with prune-like sweetness, along with delicious homemade delights and desserts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF6B584D),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // CTA Actions
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onExploreMenu,
                    icon: const Icon(Icons.cookie_outlined, size: 18),
                    label: const Text('Order Fresh Sweets'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E4A23),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Value Proposition Badges
              _buildTrustBadges(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadges(bool isMobile) {
    final badges = [
      {'icon': Icons.verified_outlined, 'title': '100% Real Butter', 'desc': 'No artificial shortening'},
      {'icon': Icons.local_fire_department_outlined, 'title': 'Fresh Batch Drops', 'desc': 'Baked on order day'},
      {'icon': Icons.inventory_2_outlined, 'title': 'Gift-Ready Box', 'desc': 'Sealed for crisp freshness'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE4D6)),
      ),
      child: isMobile
          ? Column(
              children: badges.map((b) => _badgeItem(b['icon'] as IconData, b['title'] as String, b['desc'] as String)).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: badges.map((b) => _badgeItem(b['icon'] as IconData, b['title'] as String, b['desc'] as String)).toList(),
            ),
    );
  }

  Widget _badgeItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E7DC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF8E4A23), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E1B10)),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: Color(0xFF756256)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}