import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback onExploreMenu;
  final VoidCallback onBuildCustomCake;
  final Widget? topAnnouncementWidget;

  const HeroBanner({
    super.key,
    required this.onExploreMenu,
    required this.onBuildCustomCake,
    this.topAnnouncementWidget,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0 ? constraints.maxWidth : MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = width < 960;

        return Padding(
          padding: EdgeInsets.only(
            bottom: isMobile ? 0 : 32.0,
          ),
          child: Container(
            width: double.infinity,
            height: isMobile ? (screenHeight > 600 ? screenHeight - 75 : 600) : null,
            decoration: BoxDecoration(
              color: AppColors.darkGarnet,
              // Background image for mobile only
              image: isMobile
                  ? DecorationImage(
                      image: const AssetImage('assets/images/hero_2.jpg'),
                      fit: BoxFit.cover,
                      // A solid dark overlay rather than a blend makes the image look natural but dark enough for text
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.65),
                        BlendMode.darken,
                      ),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGarnet.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (topAnnouncementWidget != null) topAnnouncementWidget!,
                isMobile
                    ? Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: _buildTextContent(isMobile),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(flex: 1, child: _buildTextContent(isMobile)),
                          Expanded(flex: 1, child: _buildImageContent(isMobile)),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 64.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Freshly Baked',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isMobile ? 22 : 32,
              fontWeight: FontWeight.w600,
              color: isMobile ? AppColors.accentGold : AppColors.bgPastelPink,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Goodness\nin Every Bite',
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontSize: isMobile ? 38 : 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'From molten Belgian chocolate chip cookies to rich chocolate cakes, we bake happiness with the finest ingredients. Fresh. Homemade. Always.',
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              height: 1.5,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: onExploreMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.textDarkBerry,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Shop Now →',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onBuildCustomCake,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Build Custom Cake',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                )
              : Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ElevatedButton(
                      onPressed: onExploreMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.textDarkBerry,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Shop Now →',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onBuildCustomCake,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Build Custom Cake',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          
          // Trust Badges
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrustBadge(Icons.eco_rounded, '100% Fresh Ingredients', isMobile),
                    const SizedBox(height: 10),
                    _buildTrustBadge(Icons.local_shipping_rounded, 'Fast & Safe Delivery', isMobile),
                    const SizedBox(height: 10),
                    _buildTrustBadge(Icons.sentiment_very_satisfied_rounded, 'Happiness Guaranteed', isMobile),
                  ],
                )
              : Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _buildTrustBadge(Icons.eco_rounded, '100% Fresh\nIngredients', isMobile),
                    _buildTrustBadge(Icons.local_shipping_rounded, 'Fast & Safe\nDelivery', isMobile),
                    _buildTrustBadge(Icons.sentiment_very_satisfied_rounded, 'Happiness\nGuaranteed', isMobile),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accentGold, size: isMobile ? 16 : 28),
        SizedBox(width: isMobile ? 4 : 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 10 : 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(bool isMobile) {
    // Only used on desktop now.
    return SizedBox(
      height: 600,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkGarnet,
                    AppColors.darkGarnet.withOpacity(0.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
