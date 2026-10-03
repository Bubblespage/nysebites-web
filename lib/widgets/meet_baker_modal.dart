import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MeetBakerModal extends StatelessWidget {
  const MeetBakerModal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile =
        screenWidth < 800; // Switch to horizontal layout for wider screens

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? 500 : 960),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgPastelPink,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Image
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/bakery_kitchen.jpg',
                  fit: BoxFit.cover,
                ),
                // Gradient overlay so the border/text pops
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right side: Content
          Expanded(
            flex: 7,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(80, 64, 40, 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildTextContent(context, isDesktop: true),
                    ),
                  ),
                ),
                // Close button top right
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textDarkBerry,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                // Floating Avatar on the dividing line
                Positioned(
                  left: -49, // Half of avatar width (98/2)
                  top: 64,
                  child: _buildAvatar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Image Area
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/images/bakery_kitchen.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              // Floating Logo / Baker Avatar
              Positioned(
                bottom: -49,
                left: 0,
                right: 0,
                child: Center(child: _buildAvatar()),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Content Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildTextContent(context, isDesktop: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgPastelPink,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentGold, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/nysebites_logo.png',
          width: 82,
          height: 82,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.cookie, color: AppColors.brandRed, size: 50),
        ),
      ),
    );
  }

  List<Widget> _buildTextContent(
    BuildContext context, {
    required bool isDesktop,
  }) {
    final align = isDesktop ? TextAlign.left : TextAlign.center;

    return [
      Text(
        'Hi, I\'m Nyse!',
        style: TextStyle(
          fontSize: isDesktop ? 36 : 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textDarkBerry,
          letterSpacing: -1.0,
        ),
        textAlign: align,
      ),
      const SizedBox(height: 8),
      Text(
        'Head Baker & Founder of Nyse Bites',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.brandRed.withOpacity(0.9),
          letterSpacing: 0.5,
        ),
        textAlign: align,
      ),
      const SizedBox(height: 24),
      Text(
        'It all started with a simple love for baking and a dream to share sweet moments with others. What began as baking cookies for family and friends quickly grew into a passionate pursuit to craft the perfect, gooey, heartwarming treats.\n\nAt Nyse Bites, we believe that every celebration (or even just a regular Tuesday) deserves a little something sweet. Every single cookie, brownie, and cake is baked fresh from scratch in our home kitchen, using only the finest ingredients and a whole lot of love.',
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: AppColors.textDarkBerry.withOpacity(0.85),
        ),
        textAlign: align,
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: isDesktop
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: AppColors.accentGold, size: 20),
          const SizedBox(width: 8),
          Text(
            'Thank you for being part of our journey.',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: AppColors.textDarkBerry.withOpacity(0.8),
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),
      SizedBox(
        width: isDesktop ? 200 : double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGarnet,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
            shadowColor: AppColors.darkGarnet.withOpacity(0.4),
          ),
          child: const Text(
            'Sweet!',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      if (!isDesktop) const SizedBox(height: 40),
    ];
  }
}
