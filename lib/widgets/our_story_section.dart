import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OurStorySection extends StatelessWidget {
  final VoidCallback? onLearnMore;

  const OurStorySection({super.key, this.onLearnMore});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 960;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24.0 : 64.0,
            vertical: isMobile ? 48.0 : 80.0,
          ),
          child: isMobile
              ? Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildTitleAndText(isMobile),
                    ),
                    const SizedBox(height: 48),
                    _buildImageCollage(isMobile),
                    const SizedBox(height: 48),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildIconsAndButton(isMobile),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleAndText(isMobile),
                              const SizedBox(height: 32),
                              _buildIconsAndButton(isMobile),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(flex: 6, child: _buildImageCollage(isMobile)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTitleAndText(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Story,',
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.w900,
            color: AppColors.textDarkBerry,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Baked',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: isMobile ? 44 : 64,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.accentGold,
                  height: 1.0,
                ),
              ),
            ),
            isMobile ? const SizedBox(width: 16) : const Spacer(),
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 0 : 16.0),
              child: Text(
                'with Love',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkBerry,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Since our first loaf came out of the oven, we\'ve been dedicated to bringing you fresh, wholesome, and delicious baked goods. Every recipe is made from scratch using premium ingredients and lots of love.',
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            height: 1.6,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIconsAndButton(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icons Row constrained to exactly the paragraph width
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureIcon(Icons.coffee, 'Premium\nIngredients'),
            _buildFeatureIcon(
              Icons.bakery_dining_outlined,
              'Made\nFresh Daily',
            ),
            _buildFeatureIcon(Icons.favorite_outline, 'Crafted\nwith Passion'),
          ],
        ),
        const SizedBox(height: 48),
        Center(
          child: OutlinedButton(
            onPressed: onLearnMore ?? () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDarkBerry,
              side: const BorderSide(color: AppColors.accentGold, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Learn More About Us',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentGold, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textDarkBerry,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCollage(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/cookiesbatch.jpg',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/hero_2.jpg',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/banana_cake_loaf.jpg',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Decorative background element
        Positioned(
          left: -40,
          bottom: 20,
          child: Icon(
            Icons.local_florist_outlined,
            color: AppColors.accentGold.withOpacity(0.2),
            size: 150,
          ),
        ),
        SizedBox(
          height: 500,
          child: Row(
            children: [
              // Large vertical image on the left (55% width)
              Expanded(
                flex: 55,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Image.asset(
                    'assets/images/hero_1.jpg',
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Two smaller horizontal images on the right (45% width)
              Expanded(
                flex: 45,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Top right decorative pattern
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.blur_on, // Placeholder for pattern
                              size: 100,
                              color: AppColors.accentGold.withOpacity(0.3),
                            ),
                          ),
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(32),
                                topLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              child: Image.asset(
                                'assets/images/hero_2.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(32),
                          bottomLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        child: Image.asset(
                          'assets/images/hero_3.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
