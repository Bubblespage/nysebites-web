import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4A3428)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black.withOpacity(0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundImage: AssetImage('assets/images/logo.jpg'),
                        ),
                        const SizedBox(width: 10),
                        const Text(
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
              // Main Product Image View
              Expanded(
                child: InteractiveViewer(
                  child: Center(
                    child: product.imgSrc.startsWith('http')
                        ? Image.network(product.imgSrc, fit: BoxFit.contain)
                        : Image.asset(product.imgSrc, fit: BoxFit.contain),
                  ),
                ),
              ),
              // Social Footer actions
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                        SizedBox(width: 14),
                        Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
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
                        icon: const Icon(Icons.camera_alt, size: 14, color: Color(0xFFDDB892)),
                        label: const Text(
                          'View post on Instagram Feed',
                          style: TextStyle(color: Color(0xFFDDB892), fontSize: 11.5),
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
    );
  }
}