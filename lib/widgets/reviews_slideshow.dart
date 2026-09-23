import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ReviewsSlideshow extends StatefulWidget {
  const ReviewsSlideshow({super.key});

  @override
  State<ReviewsSlideshow> createState() => _ReviewsSlideshowState();
}

class _ReviewsSlideshowState extends State<ReviewsSlideshow> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isHovered = false;

  final List<Map<String, String>> _fallbackReviews = [
    {
      'comment': 'The croissants are absolutely amazing! Fresh, buttery and so delicious.',
      'name': 'Sarah Johnson',
      'location': 'New York, USA',
    },
    {
      'comment': 'Best bakery I\'ve ever ordered from. The cakes are always perfect!',
      'name': 'Michael Brown',
      'location': 'London, UK',
    },
    {
      'comment': 'Amazing quality and super fast delivery. Highly recommended!',
      'name': 'Emily Davis',
      'location': 'Toronto, Canada',
    },
    {
      'comment': 'Warm them for 2 minutes and they taste like pure bakery perfection. Unmatched quality!',
      'name': 'Rain P.',
      'location': 'Sydney, Australia',
    },
    {
      'comment': 'Fast response and the eco-packaging looked so premium. Every guest asked where we ordered from!',
      'name': 'Niko V.',
      'location': 'Manila, PH',
    },
    {
      'comment': 'The balance of sea salt with rich homemade caramel in the fudge brownies is 10/10.',
      'name': 'Xander L.',
      'location': 'Berlin, Germany',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _startAutoSlide(int totalPages) {
    _autoSlideTimer?.cancel();
    if (totalPages <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isHovered && mounted) {
        final nextPage = (_currentPage + 1) % totalPages;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<List<Map<String, String>>> _chunkReviews(List<Map<String, String>> list, int chunkSize) {
    List<List<Map<String, String>>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 960;
        
        final reviewBatches = _chunkReviews(_fallbackReviews, isMobile ? 1 : 3);
        final totalPages = reviewBatches.length;

        _startAutoSlide(totalPages);

        return Container(
          width: double.infinity,
          color: AppColors.bgPastelPink,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 48.0,
            vertical: isMobile ? 32.0 : 64.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What Our Customers Say',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: isMobile ? 28 : 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDarkBerry,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Real people. Real love for our baked goods.',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textDarkBerry.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textDarkBerry,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textDarkBerry),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Carousel
              MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalPages,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final batch = reviewBatches[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: batch.map((review) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 12),
                              child: _buildReviewCard(review),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              
              // Dots
              const SizedBox(height: 24),
              if (totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalPages, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accentGold : AppColors.textDarkBerry.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, String> review) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgPastelPink,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/hero_1.jpg'), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Icon(
                Icons.format_quote_rounded,
                size: 40,
                color: AppColors.bgPastelPink.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              '"${review['comment']}"',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textDarkBerry,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textDarkBerry,
                      ),
                    ),
                    Text(
                      review['location'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                  Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                  Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                  Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                  Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
