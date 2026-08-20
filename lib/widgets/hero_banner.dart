import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback onExploreMenu;
  final VoidCallback onBuildCustomCake;

  const HeroBanner({
    super.key,
    required this.onExploreMenu,
    required this.onBuildCustomCake,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFCF7EF), Color(0xFFF7ECE0), Color(0xFFEFE1D1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 36 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (isMobile) ...[
                _buildLeftHeroContent(isMobile),
                const SizedBox(height: 36),
                _buildRightShowcaseCard(isMobile),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: _buildLeftHeroContent(isMobile)),
                    const SizedBox(width: 48),
                    Expanded(flex: 5, child: _buildRightShowcaseCard(isMobile)),
                  ],
                ),
              const SizedBox(height: 52),
              _buildTrustBadges(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftHeroContent(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF8E4A23).withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF8E4A23).withOpacity(0.25),
            ),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.local_fire_department,
                size: 16,
                color: Color(0xFF8E4A23),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'FRESH BATCH BAKED TODAY • SMALL BATCH DROPS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8E4A23),
                    letterSpacing: 0.8,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Warm, Chewy, & Irresistibly Fudgy.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: isMobile ? 38 : 44,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2B170E),
            height: 1.12,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'From molten Belgian chocolate chip cookies to dense fudge brownies and handcrafted custom layer cakes. Made from scratch daily with 100% pure dairy butter.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF6B5547),
          ),
        ),
        const SizedBox(height: 32),
        if (isMobile)
          Row(
            children: [
              Expanded(child: _buildHeroButton(isPrimary: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildHeroButton(isPrimary: false)),
            ],
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: onExploreMenu,
                icon: const Icon(Icons.cookie_outlined, size: 18),
                label: const Text('Order Fresh Sweets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E4A23),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onBuildCustomCake,
                icon: const Icon(Icons.cake_outlined, size: 18),
                label: const Text('Build Custom Cake'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3C2216),
                  side: const BorderSide(color: Color(0xFF3C2216), width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeroButton({required bool isPrimary}) {
    final style = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E4A23),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3C2216),
            side: const BorderSide(color: Color(0xFF3C2216), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          );

    return isPrimary
        ? ElevatedButton.icon(
            onPressed: onExploreMenu,
            icon: const Icon(Icons.cookie_outlined, size: 15),
            label: const Text('Order Fresh Sweets', maxLines: 1),
            style: style,
          )
        : OutlinedButton.icon(
            onPressed: onBuildCustomCake,
            icon: const Icon(Icons.cake_outlined, size: 15),
            label: const Text('Build Custom Cake', maxLines: 1),
            style: style,
          );
  }

  Widget _buildRightShowcaseCard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(60, 34, 22, 0.12),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=800&q=80',
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E1B10).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Color(0xFFF1B74C), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Top Seller Batch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShowcaseDetails(),
                      const SizedBox(height: 12),
                      _buildShowcasePrice(),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildShowcaseDetails(), _buildShowcasePrice()],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseDetails() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Belgian Choco Chip Cookie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2B170E),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Next bake timer: Out of oven in 18m',
          style: TextStyle(fontSize: 12, color: Color(0xFF8A7669)),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildShowcasePrice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5D5C5)),
      ),
      child: const Text(
        '₱65.00',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: Color(0xFF8E4A23),
        ),
      ),
    );
  }

  Widget _buildTrustBadges(bool isMobile) {
    final badges = [
      {
        'icon': Icons.verified_outlined,
        'title': '100% Real Butter',
        'desc': 'No margarine or shortening',
      },
      {
        'icon': Icons.local_fire_department_outlined,
        'title': 'Fresh Batch Drops',
        'desc': 'Baked on order day',
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Gift-Ready Box',
        'desc': 'Sealed for crisp freshness',
      },
      {
        'icon': Icons.cake_outlined,
        'title': 'Custom Layering',
        'desc': 'Personalized flavors & piping',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DACB)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(60, 34, 22, 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: badges.map((b) {
                return SizedBox(
                  width: double.infinity,
                  child: _badgeItem(
                    b['icon'] as IconData,
                    b['title'] as String,
                    b['desc'] as String,
                  ),
                );
              }).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: badges.map((b) {
                return SizedBox(
                  width: 230,
                  child: _badgeItem(
                    b['icon'] as IconData,
                    b['title'] as String,
                    b['desc'] as String,
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _badgeItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EAE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF8E4A23), size: 22),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Color(0xFF2B170E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF756256),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
