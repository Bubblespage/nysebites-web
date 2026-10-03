import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 960;

        return Padding(
          padding: EdgeInsets.only(top: isMobile ? 32.0 : 64.0, bottom: 0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.accentGold,
              // Removed border radius for full width
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Background Decorative Elements
                Positioned(
                  top: -50,
                  right: isMobile ? -50 : 200,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Content Layout
                isMobile
                    ? Column(
                        children: [
                          _buildTextContent(context, isMobile),
                          _buildImageContent(isMobile),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildTextContent(context, isMobile),
                          ),
                          Expanded(
                            flex: 5,
                            child: _buildImageContent(isMobile),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 32.0 : 64.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Send a Sweet Note\nTo Our Kitchen 💌',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isMobile ? 28 : 48,
              fontWeight: FontWeight.w900,
              color: AppColors.textDarkBerry,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Have something sweet to share? Send a note directly to our kitchen!',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              height: 1.6,
              color: AppColors.textDarkBerry.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showSweetNoteDialog(context),
            icon: const Icon(Icons.favorite, color: Colors.white, size: 20),
            label: const Text(
              'Send a Sweet Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              elevation: 8,
              shadowColor: AppColors.brandRed.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSweetNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 420,
            decoration: BoxDecoration(
              color: AppColors.bgPastelPink,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGarnet.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.darkGarnet,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Send a Sweet Note 💌',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We love hearing from you! Leave a message for our kitchen.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDarkBerry.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Name Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkGarnet.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Your Name (Optional)',
                            hintStyle: TextStyle(
                              color: AppColors.textDarkBerry.withOpacity(0.4),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Note Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkGarnet.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Type your sweet message here...',
                            hintStyle: TextStyle(
                              color: AppColors.textDarkBerry.withOpacity(0.4),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your sweet note was sent! 💖', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                backgroundColor: AppColors.darkGarnet,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Send Note',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.darkGarnet,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildImageContent(bool isMobile) {
    return SizedBox(
      height: isMobile ? 250 : 350,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background shape behind image
          Positioned(
            right: 0,
            left: isMobile ? 0 : null,
            top: 0,
            bottom: 0,
            width: isMobile ? null : 300,
            child: Container(
              margin: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 16)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: AppColors.darkGarnet,
                borderRadius: isMobile
                    ? BorderRadius.circular(32)
                    : const BorderRadius.only(
                        topLeft: Radius.circular(200),
                        bottomLeft: Radius.circular(200),
                      ),
              ),
            ),
          ),
          // Actual Image
          Positioned(
            right: isMobile ? 0 : -20,
            left: isMobile ? 0 : null,
            child: Container(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 24)
                  : EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMobile ? 24 : 16),
                child: Image.asset(
                  'assets/images/bakery_kitchen.jpg',
                  width: isMobile ? double.infinity : 350,
                  height: isMobile ? 220 : null,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Floating Text — sits on the image
          Positioned(
            top: isMobile ? 8 : 24,
            right: isMobile ? 30 : 16,
            child: Transform.rotate(
              angle: -0.2,
              child: Text(
                'Sweet~',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: isMobile ? 20 : 22,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
