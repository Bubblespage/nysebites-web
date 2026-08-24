import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OvenGallerySection extends StatefulWidget {
  const OvenGallerySection({super.key});

  @override
  State<OvenGallerySection> createState() => _OvenGallerySectionState();
}

class _OvenGallerySectionState extends State<OvenGallerySection> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _galleryPosts = [
    {
      'image': 'assets/images/cake1.jpg',
      'caption':
          'Custom superhero & kitty themed two-tier birthday masterpiece! 🦸‍♀️🐱✨',
      'likes': '448',
      'comments': '14',
    },
    {
      'image': 'assets/images/cake2.jpg',
      'caption':
          'Delicate white and gold christening cake with blessed details. 🕊️✨',
      'likes': '512',
      'comments': '29',
    },
    {
      'image': 'assets/images/cake3.jpg',
      'caption':
          'Adorable Stitch & Cinnamoroll blue pastel celebration cake! 💙🧁',
      'likes': '820',
      'comments': '18',
    },
    {
      'image': 'assets/images/cake14.jpg',
      'caption':
          'Custom truck topper birthday cake with vibrant red & gold frosting. 🚛🔥',
      'likes': '630',
      'comments': '41',
    },
    {
      'image': 'assets/images/cake21.jpg',
      'caption': 'Action-packed Paw Patrol themed two-tone birthday cake! 🐾🐶',
      'likes': '890',
      'comments': '52',
    },
    {
      'image': 'assets/images/cake7.jpg',
      'caption':
          'Sweet baby blue christening cake with custom topper & golden stars. ⭐👶',
      'likes': '675',
      'comments': '9',
    },
    {
      'image': 'assets/images/cake8.jpg',
      'caption':
          'Two-tier pastel pink Peppa Pig birthday wonderland cake! 🐷💖',
      'likes': '710',
      'comments': '33',
    },
    {
      'image': 'assets/images/cake9.jpg',
      'caption':
          'Vibrant pink Happy Birthday topper with gorgeous buttercream rose swirls. 🌹✨',
      'likes': '940',
      'comments': '65',
    },
    {
      'image': 'assets/images/cake10.jpg',
      'caption':
          'Magical Vulpix Pokémon ice-blue snowflake frosted masterpiece. ❄️🦊',
      'likes': '455',
      'comments': '21',
    },
    {
      'image': 'assets/images/cake11.jpg',
      'caption':
          'Edgy black and pink Kuromi celebration cake with sweet macarons! 🖤🩷',
      'likes': '620',
      'comments': '38',
    },
    {
      'image': 'assets/images/cake12.jpg',
      'caption':
          'Stunning pink and black Kuromi custom lettering birthday cake. 🎀🍰',
      'likes': '389',
      'comments': '12',
    },
    {
      'image': 'assets/images/cake13.jpg',
      'caption':
          'Enchanting Harry Potter themed cake complete with sorting hat & wand! ⚡🧙‍♂️',
      'likes': '830',
      'comments': '47',
    },
    {
      'image': 'assets/images/cake5.jpg',
      'caption':
          'Decadent chocolate drip cake topped with mini liquor bottle & truffles. 🍫🍾',
      'likes': '515',
      'comments': '24',
    },
    {
      'image': 'assets/images/cake15.jpg',
      'caption':
          'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
      'likes': '799',
      'comments': '59',
    },
    {
      'image': 'assets/images/cake16.jpg',
      'caption':
          'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
      'likes': '799',
      'comments': '59',
    },
    {
      'image': 'assets/images/cake17.jpg',
      'caption':
          'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
      'likes': '799',
      'comments': '59',
    },
    {
      'image': 'assets/images/cake18.jpg',
      'caption':
          'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
      'likes': '799',
      'comments': '59',
    },
    {
      'image': 'assets/images/cake19.jpg',
      'caption':
          'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
      'likes': '799',
      'comments': '59',
    },
    {
      'image': 'assets/images/cake20.jpg',
      'caption':
          'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
      'likes': '799',
      'comments': '59',
    },
    {
      'image': 'assets/images/cake6.jpg',
      'caption':
          'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
      'likes': '799',
      'comments': '59',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showPostLightbox(BuildContext context, Map<String, String> post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(60, 34, 22, 0.25),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF2E9),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEFE4D6)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8E4A23),
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage(
                                'assets/images/logo.jpg',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Nyse Bites Gallery',
                            style: TextStyle(
                              color: Color(0xFF2E1B10),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF756256),
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Main Photo View
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: InteractiveViewer(
                      child: Center(
                        child: Image.asset(post['image']!, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                // Bottom Caption & Stats
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFBF7),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post['likes']!,
                            style: const TextStyle(
                              color: Color(0xFF2E1B10),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF756256),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post['comments']!,
                            style: const TextStyle(
                              color: Color(0xFF2E1B10),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: 'nysebites ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E1B10),
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: post['caption']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF756256),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 32 : 54,
        horizontal: isMobile ? 16 : 24,
      ),
      color: const Color(0xFFFAF4ED),
      child: Column(
        children: [
          const Text(
            'Oven Fresh Gallery 🤎',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E1B10),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A closer look at our daily small-batch bakes, custom cakes, and sweet moments.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF756256), fontSize: 13.5),
          ),
          const SizedBox(height: 28),

          // Carousel Row with Navigation Arrows
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250, maxHeight: 290),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _galleryPosts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
                  itemBuilder: (context, index) {
                    final post = _galleryPosts[index];
                    return _HoverableGalleryCard(
                      post: post,
                      onTap: () => _showPostLightbox(context, post),
                    );
                  },
                ),
                // Left Arrow Button
                Positioned(
                  left: 4,
                  child: FloatingActionButton.small(
                    heroTag: 'gal_left_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E1B10),
                    elevation: 4,
                    onPressed: _scrollLeft,
                    child: const Icon(Icons.chevron_left_rounded, size: 26),
                  ),
                ),
                // Right Arrow Button
                Positioned(
                  right: 4,
                  child: FloatingActionButton.small(
                    heroTag: 'gal_right_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E1B10),
                    elevation: 4,
                    onPressed: _scrollRight,
                    child: const Icon(Icons.chevron_right_rounded, size: 26),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableGalleryCard extends StatefulWidget {
  final Map<String, String> post;
  final VoidCallback onTap;

  const _HoverableGalleryCard({required this.post, required this.onTap});

  @override
  State<_HoverableGalleryCard> createState() => _HoverableGalleryCardState();
}

class _HoverableGalleryCardState extends State<_HoverableGalleryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 1),
          width: 240,
          child: AspectRatio(
            aspectRatio: 1 / 1, // Perfectly square, clean proportions
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF8E4A23)
                      : const Color(0xFFE5D5C5),
                  width: _isHovered ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(60, 34, 22, _isHovered ? 0.18 : 0.08),
                    blurRadius: _isHovered ? 22 : 10,
                    offset: Offset(0, _isHovered ? 10 : 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(widget.post['image']!, fit: BoxFit.cover),
                    // Hover Gradient Overlay with cute branding & stats
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.black.withOpacity(0.85),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.bakery_dining_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Nyse Bites Fresh',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.collections_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                            // Cute Center Heart Icon
                            const Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFE25C5C),
                                size: 42,
                              ),
                            ),
                            // Like & Comment Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.post['likes']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.post['comments']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
