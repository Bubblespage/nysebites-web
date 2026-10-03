import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

class GlobalSearchOverlay extends StatelessWidget {
  final String query;
  final VoidCallback onNavigateToStory;
  final VoidCallback onNavigateToContact;
  final VoidCallback onNavigateToGallery;
  final VoidCallback onTrackOrder;
  final Function(Product) onProductClick;
  final VoidCallback onClose;
  final Stream<QuerySnapshot<Map<String, dynamic>>> productsStream;

  const GlobalSearchOverlay({
    super.key,
    required this.query,
    required this.onNavigateToStory,
    required this.onNavigateToContact,
    required this.onNavigateToGallery,
    required this.onTrackOrder,
    required this.onProductClick,
    required this.onClose,
    required this.productsStream,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    
    final normalizedQuery = query.trim().toLowerCase();
    
    // Determine smart suggestion
    String? smartTitle;
    String? smartActionText;
    VoidCallback? smartAction;
    IconData? smartIcon;

    if (normalizedQuery.contains('story') || normalizedQuery.contains('about')) {
      smartTitle = "Looking to learn more about us?";
      smartActionText = "Read Our Story";
      smartAction = onNavigateToStory;
      smartIcon = Icons.auto_stories_rounded;
    } else if (normalizedQuery.contains('contact') || normalizedQuery.contains('help') || normalizedQuery.contains('message')) {
      smartTitle = "Need help or have a question?";
      smartActionText = "Contact Us";
      smartAction = onNavigateToContact;
      smartIcon = Icons.mail_outline_rounded;
    } else if (normalizedQuery.contains('gallery') || normalizedQuery.contains('photo') || normalizedQuery.contains('picture')) {
      smartTitle = "Want to see our past creations?";
      smartActionText = "View Gallery";
      smartAction = onNavigateToGallery;
      smartIcon = Icons.photo_library_outlined;
    } else if (normalizedQuery.contains('track') || normalizedQuery.contains('order') || normalizedQuery.contains('status') || normalizedQuery.startsWith('#') || normalizedQuery.startsWith('ord-')) {
      smartTitle = "Looking for an existing order?";
      smartActionText = "Track Order";
      smartAction = onTrackOrder;
      smartIcon = Icons.local_shipping_outlined;
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgPastelPink, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.bgPastelPink)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Search Results for "$query"',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textDarkBerry,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onClose,
                      child: const Icon(Icons.close_rounded, size: 20, color: AppColors.textDarkBerry),
                    ),
                  ],
                ),
              ),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (smartAction != null)
                        _buildSmartSuggestion(smartTitle!, smartActionText!, smartAction, smartIcon!),
                      
                      // Products StreamBuilder
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: productsStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(child: CircularProgressIndicator(color: AppColors.textDarkBerry)),
                            );
                          }

                          final docs = snapshot.data!.docs;
                          final matchingProducts = docs.map((d) => Product.fromMap(d.id, d.data())).where((p) {
                            final nameMatch = p.name.toLowerCase().contains(normalizedQuery);
                            final catMatch = p.category.toLowerCase().contains(normalizedQuery);
                            return nameMatch || catMatch;
                          }).toList();

                          if (matchingProducts.isEmpty) {
                            return smartAction == null
                                ? Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                        "No treats match your search.",
                                        style: TextStyle(
                                          color: AppColors.textDarkBerry.withValues(alpha: 0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  'MENU ITEMS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDarkBerry.withValues(alpha: 0.5),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              ...matchingProducts.map((p) => _buildProductItem(p)).toList(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartSuggestion(String title, String actionText, VoidCallback action, IconData icon) {
    return InkWell(
      onTap: () {
        action();
        onClose();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgPastelPink.withValues(alpha: 0.3),
          border: const Border(bottom: BorderSide(color: AppColors.bgPastelPink)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.brandRed, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMART SUGGESTION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandRed.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDarkBerry,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDarkBerry),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return InkWell(
      onTap: () {
        onProductClick(product);
        onClose();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.bgPastelPink, width: 0.5)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imgSrc.isNotEmpty
                  ? Image.network(
                      product.imgSrc,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                    )
                  : _buildFallbackIcon(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDarkBerry,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.brandRed.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.bgPastelPink,
      child: const Center(
        child: Icon(Icons.cookie, color: AppColors.accentGold, size: 24),
      ),
    );
  }
}
