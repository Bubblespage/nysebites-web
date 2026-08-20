import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  // Cross-platform URL Launcher method
  Future<void> _openUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (kIsWeb) {
        // On Flutter Web, launch directly into a new browser tab
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

  // Cross-platform Email Launcher method
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
              // Main Footer Columns
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
                        width: compactColumnWidth ?? 280,
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

                      // Contact & Email Column
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
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    _sendEmail('aromanteacup@gmail.com'),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFFDDB892),
                                      size: 18,
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        'aromanteacup@gmail.com',
                                        style: TextStyle(
                                          color: Color(0xFFEFE4D6),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    'Fresh Daily Bakehouse',
                                    style: TextStyle(
                                      color: Color(0xFFD1C5BC),
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Social Media & Hours Column
                      SizedBox(
                        width: compactColumnWidth ?? 240,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Follow Our Bakes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                // Instagram Link Button
                                _FooterSocialBtn(
                                  icon: Icons.camera_alt_outlined,
                                  label: 'Instagram',
                                  onTap: () => _openUrl(
                                    'https://www.instagram.com/nysebites?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==',
                                  ),
                                ),
                                // Facebook Link Button
                                _FooterSocialBtn(
                                  icon: Icons.facebook,
                                  label: 'Facebook',
                                  onTap: () => _openUrl(
                                    'https://www.facebook.com/NYSEbites',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Mon – Sat: 9:00 AM – 6:00 PM',
                              style: TextStyle(
                                color: Color(0xFFA89A90),
                                fontSize: 12,
                              ),
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

              // Bottom Copyright
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
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3C2216),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4A3428)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFDDB892), size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
