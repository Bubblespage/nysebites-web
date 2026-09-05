import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class HeroBanner extends StatefulWidget {
  final VoidCallback onExploreMenu;
  final VoidCallback onBuildCustomCake;

  const HeroBanner({
    super.key,
    required this.onExploreMenu,
    required this.onBuildCustomCake,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Timer? _carouselTimer;
  int _currentIndex = 0;

  final List<String> _carouselImages = [
    'assets/images/premium_baked_goods.jpg',
    'assets/images/cookiesbatch.jpg',
  ];
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1400)
    );
    _animController.forward();

    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _carouselImages.length;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0 ? constraints.maxWidth : MediaQuery.of(context).size.width;
        final isMobile = width < 960;
        final screenHeight = MediaQuery.of(context).size.height;
        final dynamicHeight = isMobile ? (screenHeight - 100) : 600.0;

        return Container(
          width: double.infinity,
          height: dynamicHeight,
          margin: EdgeInsets.only(bottom: isMobile ? 48.0 : 64.0),
          child: Stack(
            children: [
              // 1. Background Carousel
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 2),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Image.asset(
                    _carouselImages[_currentIndex],
                    key: ValueKey<int>(_currentIndex),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              // 2. Dark Overlay for Legibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1F1209).withOpacity(0.6), // Dark warm brown overlay
                        const Color(0xFF1F1209).withOpacity(0.8), 
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 3. Foreground Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isMobile ? 40 : 80, 
                    bottom: isMobile ? 24 : 32,
                    left: isMobile ? 24 : 48,
                    right: isMobile ? 24 : 48,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter, // Anchor from top instead of center
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: _buildCenteredTextContent(isMobile),
                    ),
                  ),
                ),
              ),
            // Close the Stack and Container
            ],
          ), // closes Stack
        ); // closes Container
      },
    );
  }

  Widget _buildCenteredTextContent(bool isMobile) {
    return _FadeSlideTransition(
      animation: CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'BAKED FRESH WITH LOVE DAILY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Warm, Chewy, &\nIrresistibly Cute.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isMobile ? 34 : 58,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1,
              shadows: const [
                Shadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'From molten Belgian chocolate chip cookies to artisanal custom layer cakes. Made from scratch daily with 100% pure dairy butter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
                height: 1.6,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 24 : 48),
          if (isMobile)
            Column(
              children: [
                _buildHeroButton(isPrimary: true, isMobile: true),
                const SizedBox(height: 16),
                _buildHeroButton(isPrimary: false, isMobile: true),
              ],
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildHeroButton(isPrimary: true, isMobile: false),
                _buildHeroButton(isPrimary: false, isMobile: false),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeroButton({required bool isPrimary, required bool isMobile}) {
    final padding = EdgeInsets.symmetric(
      horizontal: isMobile ? 16 : 40, 
      vertical: isMobile ? 12 : 24,
    );

    final style = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E4A23),
            foregroundColor: Colors.white,
            padding: padding,
            shape: const StadiumBorder(),
            elevation: 12,
            shadowColor: const Color(0xFF8E4A23).withOpacity(0.6),
            textStyle: TextStyle(
              fontSize: isMobile ? 12 : 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2),
            padding: padding,
            shape: const StadiumBorder(),
            textStyle: TextStyle(
              fontSize: isMobile ? 12 : 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          );

    final button = isPrimary
        ? ElevatedButton.icon(
            onPressed: widget.onExploreMenu,
            icon: const Icon(Icons.cookie, size: 20),
            label: const Text('Order Fresh Sweets'),
            style: style,
          )
        : OutlinedButton.icon(
            onPressed: widget.onBuildCustomCake,
            icon: const Icon(Icons.cake, size: 20),
            label: const Text('Build Custom Cake'),
            style: style,
          );

    return isMobile ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const _FadeSlideTransition({
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, childWidget) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - animation.value)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}