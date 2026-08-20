import 'dart:async';
import 'package:flutter/material.dart';

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

  // Review triplets (3 cards per slide on desktop)
  final List<List<Map<String, String>>> _reviewBatches = [
    [
      {
        'rating': '★★★★',
        'comment':
            'The customized red velvet cake with gold leaf was the highlight of our party!',
        'name': '- Law R.',
      },
      {
        'rating': '★★★★★',
        'comment':
            'Ordered a batch of fudge brownies for a family gathering and they were gone in minutes.',
        'name': '- Mark D.',
      },
      {
        'rating': '★★★★★',
        'comment':
            'Love the less-sweet option! Rich flavors without an overwhelming sugar crash.',
        'name': '- Hanah L.',
      },
    ],
    [
      {
        'rating': '★★★★',
        'comment':
            'Warm them for 2 minutes and they taste like pure bakery perfection. Unmatched quality!',
        'name': '- Rain P.',
      },
      {
        'rating': '★★★★★',
        'comment':
            'Fast response and the eco-packaging looked so premium. Every guest asked where we ordered from!',
        'name': '- Niko V.',
      },
      {
        'rating': '★★★★★',
        'comment':
            'The balance of sea salt with rich homemade caramel in the fudge brownies is 10/10.',
        'name': '- Xander L.',
      },
    ],
    [
      {
        'rating': '★★★',
        'comment':
            'I requested custom oat-milk frosting in the notes box and Nyse Bites delivered perfectly!',
        'name': '- Patricia L.',
      },
      {
        'rating': '★★★★',
        'comment':
            'Loaded with toasted walnuts and silky spiced cinnamon cream. Best carrot cake in town.',
        'name': '- Angelo R.',
      },
      {
        'rating': '★★★★★',
        'comment':
            'The matcha white chocolate cookies are thick, gooey, and packed with real Uji matcha flavor.',
        'name': '- Sophia K.',
      },
    ],
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isHovered && mounted) {
        final pageCount = MediaQuery.of(context).size.width < 980
            ? _reviewBatches.expand((batch) => batch).length
            : _reviewBatches.length;
        final nextPage = (_currentPage + 1) % pageCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 980;
    final mobileReviews = _reviewBatches.expand((batch) => batch).toList();
    final mobileCardWidth = screenWidth > 40
        ? (screenWidth - 40).clamp(200.0, 310.0)
        : 280.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF7ECE1),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 28 : 48,
        horizontal: 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            children: [
              // Title
              const Text(
                'Loved By Sweet Lovers',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E1B10),
                ),
              ),
              const SizedBox(height: 28),

              // Sliding Cards Container
              MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: SizedBox(
                  height: isMobile ? 200 : 175,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: isMobile
                        ? mobileReviews.length
                        : _reviewBatches.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final batch = _reviewBatches[index];

                      if (isMobile) {
                        return Center(
                          child: _buildSmallCard(
                            mobileReviews[index],
                            width: mobileCardWidth,
                          ),
                        );
                      }

                      // Display exact 3 side-by-side small cards on desktop
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: batch.map((review) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _buildSmallCard(review, width: 310),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Pagination Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  isMobile ? mobileReviews.length : _reviewBatches.length,
                  (index) {
                    final isActive = index == _currentPage;
                    return InkWell(
                      onTap: () => _goToPage(index),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF8E4A23)
                              : const Color(0xFFDDB892),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Exact card size & proportions matching your screenshot
  Widget _buildSmallCard(Map<String, String> review, {required double width}) {
    return Container(
      width: width,
      height: 165,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE4D6)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(60, 34, 22, 0.04),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 5-Star Row
          Text(
            review['rating']!,
            style: const TextStyle(
              color: Color(0xFF8E4A23),
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),

          // Comment Text
          Text(
            '"${review['comment']}"',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF2E1B10),
            ),
          ),

          // Customer Signature
          Text(
            review['name']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF756256),
            ),
          ),
        ],
      ),
    );
  }
}
