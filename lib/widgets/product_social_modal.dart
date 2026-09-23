import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

class ProductSocialModal extends StatelessWidget {
  final Product product;

  const ProductSocialModal({super.key, required this.product});

  Future<void> _openInstagram() async {
    const urlString = 'https://www.instagram.com/nysebites';
    final Uri uri = Uri.parse(urlString);
    try {
      if (kIsWeb) {
        await launchUrl(uri, webOnlyWindowName: '_blank');
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening Instagram: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktopOrTablet = mediaQuery.size.width >= 768;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktopOrTablet ? 32 : 16,
        vertical: isDesktopOrTablet ? 24 : 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktopOrTablet ? 920 : 500,
          maxHeight: isDesktopOrTablet ? 620 : 580,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.textDarkBerry),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: isDesktopOrTablet
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left: Full-height image viewer
        Expanded(
          flex: 6,
          child: Container(
            color: AppColors.brandRed,
            child: InteractiveViewer(
              child: Center(
                child: product.imgSrc.startsWith('http')
                    ? Image.network(product.imgSrc, fit: BoxFit.contain)
                    : (product.imgSrc.isNotEmpty
                        ? Image.asset(product.imgSrc, fit: BoxFit.contain)
                        : const Icon(Icons.cake, color: Colors.white54, size: 60)),
              ),
            ),
          ),
        ),

        // Vertical divider
        Container(width: 1, color: AppColors.brandRed),

        // Right: Instagram style details & comments sidebar
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.brandRed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.brandRed),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              'assets/images/nysebites_logo.png',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'nysebites',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                'Original Pastry & Cakes',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Caption & Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage(
                                'assets/images/nysebites_logo.png',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'nysebites ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${product.name}\n\n',
                                      style: const TextStyle(
                                        color: AppColors.brandRed,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: product.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Actions & Instagram link
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.brandRed)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 22,
                          ),
                          SizedBox(width: 14),
                          Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 14),
                          Icon(
                            Icons.send_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '842 likes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openInstagram,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.textDarkBerry),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 15,
                            color: AppColors.bgPastelPink,
                          ),
                          label: const Text(
                            'View on Instagram Feed',
                            style: TextStyle(
                              color: AppColors.bgPastelPink,
                              fontSize: 12,
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
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.black.withValues(alpha: 0.8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage('assets/images/nysebites_logo.png'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'nysebites',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Image
        Expanded(
          child: InteractiveViewer(
            child: Center(
              child: product.imgSrc.startsWith('http')
                  ? Image.network(product.imgSrc, fit: BoxFit.contain)
                  : (product.imgSrc.isNotEmpty
                      ? Image.asset(product.imgSrc, fit: BoxFit.contain)
                      : const Icon(Icons.cake, color: Colors.white54, size: 60)),
            ),
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black.withValues(alpha: 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                  SizedBox(width: 14),
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 14),
                  Icon(Icons.send_outlined, color: Colors.white, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '842 likes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  text: 'nysebites ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12.5,
                  ),
                  children: [
                    TextSpan(
                      text: '${product.name} — ${product.description}',
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: _openInstagram,
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: AppColors.bgPastelPink,
                  ),
                  label: const Text(
                    'View post on Instagram Feed',
                    style: TextStyle(color: AppColors.bgPastelPink, fontSize: 11.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
