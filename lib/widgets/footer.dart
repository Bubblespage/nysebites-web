import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class Footer extends StatelessWidget {
  final VoidCallback? onHomeClick;
  final VoidCallback? onShopClick;
  final VoidCallback? onAboutClick;

  const Footer({
    super.key,
    this.onHomeClick,
    this.onShopClick,
    this.onAboutClick,
  });

  Future<void> _openUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (kIsWeb) {
        await launchUrl(uri, webOnlyWindowName: '_blank');
      } else {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      }
    } catch (e) {
      debugPrint('Error launching URL ($urlString): $e');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Nyse Bites Inquiry',
    );
    try {
      if (kIsWeb) {
        await launchUrl(emailLaunchUri, webOnlyWindowName: '_self');
      } else {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint('Error launching mailto: $e');
    }
  }

  Future<void> _callPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri);
    } catch (e) {
      debugPrint('Error launching phone: $e');
    }
  }

  void _showPolicyDialog(BuildContext context, {required bool isPrivacy}) {
    final isPrivacyPolicy = isPrivacy;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandRed.withOpacity(0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Themed Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.brandRed,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPrivacyPolicy
                              ? Icons.shield_outlined
                              : Icons.article_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPrivacyPolicy
                                  ? 'Privacy Policy'
                                  : 'Terms & Conditions',
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              isPrivacyPolicy
                                  ? 'Your trust is our secret ingredient 🤎'
                                  : 'Baked with honesty, served with care 🍪',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: isPrivacyPolicy
                          ? _buildPrivacyContent()
                          : _buildTermsContent(),
                    ),
                  ),
                ),

                // Footer button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Got it, thanks!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPrivacyContent() {
    final sections = [
      _PolicySection(
        emoji: '✨',
        title: '1. Information We Collect',
        body:
            'When you place an order or create an account on Nyse Bites, we collect your name, contact number, delivery address, and order details. This information is used solely to fulfill your order and improve your experience with us.',
      ),
      _PolicySection(
        emoji: '🔒',
        title: '2. How We Use Your Data',
        body:
            'Your information is used to process orders, send order confirmations, and communicate delivery updates. We do not sell, trade, or rent your personal information to third parties.',
      ),
      _PolicySection(
        emoji: '📦',
        title: '3. Data Storage & Security',
        body:
            'All data is securely stored using Firebase (Google Cloud). We apply industry-standard security practices to protect your information from unauthorized access.',
      ),
      _PolicySection(
        emoji: '📸',
        title: '4. Profile Photos',
        body:
            'Profile images you upload are stored securely and only visible to you within your account. They are never shared publicly.',
      ),
      _PolicySection(
        emoji: '🔔',
        title: '5. Push Notifications',
        body:
            'If you opt in, we may send you order updates and occasional promotions. You can turn this off anytime in your profile settings.',
      ),
      _PolicySection(
        emoji: '📩',
        title: '6. Contact Us',
        body:
            'For any privacy concerns, reach us at nysebites@gmail.com or message us on Facebook at @NYSEbites. We\'re always happy to help! 🤎',
      ),
    ];
    return sections;
  }

  List<Widget> _buildTermsContent() {
    final sections = [
      _PolicySection(
        emoji: '🍪',
        title: '1. Quality Commitment',
        body:
            'All Nyse Bites products are made fresh in small batches using quality ingredients. We take pride in every treat we bake, and your satisfaction is our top priority.',
      ),
      _PolicySection(
        emoji: '📅',
        title: '2. Order Lead Times',
        body:
            'Standard orders may be available for same-day or next-day pickup/delivery depending on availability. Custom cakes require a minimum of 2 weeks advance notice. Please plan accordingly!',
      ),
      _PolicySection(
        emoji: '❌',
        title: '3. No Cancellations',
        body:
            'Since our treats are freshly baked to order, all submitted orders are final. Please double-check your cart before checking out. For urgent concerns, message us directly on Facebook.',
      ),
      _PolicySection(
        emoji: '🚚',
        title: '4. Delivery Policy',
        body:
            'We offer delivery via GrabCar and Lalamove for your convenience. Delivery fees are shouldered by the customer and depend on your location. Exact delivery times will be communicated after your order is confirmed.',
      ),
      _PolicySection(
        emoji: '💳',
        title: '5. Payment',
        body:
            'We accept GCash payments. Payment details will be provided after your order is confirmed. Orders are only processed upon receipt of payment.',
      ),
      _PolicySection(
        emoji: '🎂',
        title: '6. Custom Cake Policy',
        body:
            'Custom cake orders require a 50% deposit upon confirmation. We reserve the right to decline designs that are beyond our current capabilities.',
      ),
      _PolicySection(
        emoji: '📬',
        title: '7. Contact & Concerns',
        body:
            'For questions, order modifications, or complaints, contact us at nysebites@gmail.com or via Facebook @NYSEbites. We will do our best to respond within 24 hours.',
      ),
    ];
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.textDarkBerry,
      padding: const EdgeInsets.only(top: 64, bottom: 24, left: 24, right: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;

                  return Wrap(
                    spacing: 40,
                    runSpacing: 40,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      // Column 1: Brand & Story
                      SizedBox(
                        width: isMobile ? double.infinity : 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/nysebites_logo.png',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.cookie_outlined,
                                    color: AppColors.accentGold,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Nyse Bites.',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Freshly baked goods, made with love. Because life is sweeter with something homemade.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _FooterSocialBtn(
                                  icon: Icons.camera_alt_outlined,
                                  onTap: () => _openUrl(
                                      'https://www.instagram.com/nysebites'),
                                ),
                                const SizedBox(width: 12),
                                _FooterSocialBtn(
                                  icon: Icons.facebook,
                                  onTap: () => _openUrl(
                                      'https://www.facebook.com/NYSEbites'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Column 2: Quick Links
                      SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Links',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _footerLink('Home', onHomeClick ?? () {}),
                            _footerLink('Shop', onShopClick ?? () {}),
                            _footerLink('About', onAboutClick ?? () {}),
                            _footerLink(
                              'Privacy Policy',
                              () => _showPolicyDialog(context, isPrivacy: true),
                            ),
                            _footerLink(
                              'Terms & Conditions',
                              () =>
                                  _showPolicyDialog(context, isPrivacy: false),
                            ),
                          ],
                        ),
                      ),

                      // Column 3: Categories
                      SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _footerLink('Cookies', onShopClick ?? () {}),
                            _footerLink('Cakes', onShopClick ?? () {}),
                            _footerLink('Brownies', onShopClick ?? () {}),
                            _footerLink('Cake Loafs', onShopClick ?? () {}),
                          ],
                        ),
                      ),

                      // Column 4: Contact Us
                      SizedBox(
                        width: 240,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Us',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppColors.accentGold, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Carsadang Bago II\nImus, Cavite, PH',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _callPhone('+639950829180'),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone,
                                      color: AppColors.accentGold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+63 995 082 9180',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _sendEmail('nysebites@gmail.com'),
                              child: Row(
                                children: [
                                  const Icon(Icons.email,
                                      color: AppColors.accentGold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'nysebites@gmail.com',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
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
                },
              ),
              const SizedBox(height: 48),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2026 Nyse Bites. All rights reserved.',
                    style:
                        TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        'Made with ',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      const Icon(Icons.favorite,
                          color: AppColors.accentGold, size: 12),
                      Text(
                        ' for sweet lovers',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.accentGold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Policy Section Widget ──
class _PolicySection extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;

  const _PolicySection({
    required this.emoji,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDarkBerry,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              body,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textDarkBerry.withOpacity(0.75),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Divider(
              color: AppColors.bgPastelPink.withOpacity(0.8),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSocialBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FooterSocialBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
