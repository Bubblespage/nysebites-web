import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

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

  void _showCutePolicyDialog(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    List<String> sections,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(60, 34, 22, 0.22),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E7DC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: const Color(0xFF8E4A23),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2E1B10),
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF8E4A23),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF756256)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFEFE4D6)),
                const SizedBox(height: 12),

                // Content Body
                Expanded(
                  child: ListView.builder(
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          sections[index],
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF5A4438),
                            height: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Footer button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E1B10),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Got it, thanks! 🍪',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2E1B10),
      padding: const EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compactColumnWidth = constraints.maxWidth < 600
                      ? constraints.maxWidth
                      : null;

                  return Wrap(
                    spacing: 40,
                    runSpacing: 32,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      // Brand & Story Column
                      SizedBox(
                        width: compactColumnWidth ?? 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/logo.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.cookie_outlined,
                                        color: Color(0xFF8E4A23),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Nyse Bites.',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Handcrafted cookies, brownies, and signature cakes made from scratch daily using premium real butter and chocolates.',
                              style: TextStyle(
                                color: Color(0xFFD1C5BC),
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Customer Care & Cute Legal Links Column
                      SizedBox(
                        width: compactColumnWidth ?? 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer Care',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _footerLink(
                              'Privacy Policy',
                              () => _showCutePolicyDialog(
                                context,
                                'Privacy Policy',
                                Icons.privacy_tip_outlined,
                                'Your trust is our secret ingredient 🤎',
                                [
                                  '✨ 1. Information We Collect: When you place an order, we collect your name, contact number, delivery address, and GCash receipt references to ensure smooth fulfillment.',
                                  '🔒 2. Data Protection: All personal data and GCash payment details are stored securely. We adhere to strict privacy guidelines and do not sell, trade, or share your private information with third parties.',
                                  '🛵 3. Delivery Usage: Your address and contact number are securely provided to our assigned delivery dispatchers solely for the purpose of bringing your fresh bakes to your doorstep.',
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _footerLink(
                              'Terms & Conditions',
                              () => _showCutePolicyDialog(
                                context,
                                'Terms & Conditions',
                                Icons.gavel_outlined,
                                'Baked fresh with love and guidelines 📜',
                                [
                                  '🍪 1. Fresh Batch Quality: All cookies, brownies, and cakes are baked in small batches daily using premium ingredients. Visual toppings may slightly vary depending on seasonal availability.',
                                  '💳 2. Payment & Verification: We strictly accept GCash payments only. A valid GCash receipt reference must be provided for verification. Your payment details are kept fully private and secure.',
                                  '🎂 3. Custom Cakes & Cancellations: Custom cake commissions require early notice. Order cancellations or modifications are only accommodated before kitchen preparation begins.',
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _footerLink(
                              'Frequently Asked Questions (FAQ)',
                              () => _showCutePolicyDialog(
                                context,
                                'Frequently Asked Questions',
                                Icons.help_outline_rounded,
                                'Everything you need to know about our bakes ✨',
                                [
                                  '🛵 Q: How does the delivery model work?\nA: We utilize GrabCar and Lalamove-based dispatching! You can select Standard or Priority Express delivery rates calculated right at checkout.',
                                  '👀 Q: How do I track my active order?\nA: Simply tap the floating "Track Order" button on your screen anytime to view real-time kitchen preparation status and assigned rider details!',
                                  '📦 Q: Can I choose box sizes for cookies?\nA: Yes! Our artisanal cookies are available in convenient Box of 4 or Box of 6 sizes with special bundle pricing.',
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Contact & Location Column
                      SizedBox(
                        width: compactColumnWidth ?? 240,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Get In Touch',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 14),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _sendEmail('nysebites@gmail.com'),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFFDDB892),
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'nysebites@gmail.com',
                                      style: TextStyle(
                                        color: Color(0xFFEFE4D6),
                                        fontSize: 12.5,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: const [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFFDDB892),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Carsadang Bago II • Imus, Cavite',
                                    style: TextStyle(
                                      color: Color(0xFFD1C5BC),
                                      fontSize: 12.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                _FooterSocialBtn(
                                  icon: Icons.camera_alt_outlined,
                                  label: 'Instagram',
                                  onTap: () => _openUrl(
                                    'https://www.instagram.com/nysebites',
                                  ),
                                ),
                                _FooterSocialBtn(
                                  icon: Icons.facebook,
                                  label: 'Facebook',
                                  onTap: () => _openUrl(
                                    'https://www.facebook.com/NYSEbites',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              const Divider(color: Color(0xFF4A3428)),
              const SizedBox(height: 16),
              const Text(
                '© 2026 Nyse Bites Bakery. All rights reserved.',
                style: TextStyle(color: Color(0xFFA89A90), fontSize: 12),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          title,
          style: const TextStyle(color: Color(0xFFD1C5BC), fontSize: 12.5),
        ),
      ),
    );
  }
}

class _FooterSocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterSocialBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3C2216),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4A3428)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFDDB892), size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
