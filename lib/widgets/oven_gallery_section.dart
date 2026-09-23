import 'package:flutter/material.dart';
import 'instagram_post_modal.dart';
import '../theme/app_colors.dart';

class OvenGallerySection extends StatefulWidget {
  const OvenGallerySection({super.key});

  @override
  State<OvenGallerySection> createState() => _OvenGallerySectionState();
}

class _OvenGallerySectionState extends State<OvenGallerySection> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (_scrollController.offset - 250).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (_scrollController.offset + 250).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Standard Cakes',
      'subtitle': 'Classic & Elegant',
      'image': 'assets/images/standard1.jpg',
      'items': [
        {
          'image': 'assets/images/standard1.jpg',
          'caption': 'Vibrant pink Happy Birthday topper with gorgeous buttercream rose swirls. 🌹✨',
          'likes': '940',
          'comments': '65',
        },
        {
          'image': 'assets/images/standard2.jpg',
          'caption': 'Classic red and white piped celebration cake with festive ribbon bows. 🎀',
          'likes': '410',
          'comments': '18',
        },
        {
          'image': 'assets/images/standard3.jpg',
          'caption': 'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
          'likes': '799',
          'comments': '59',
        },
        {
          'image': 'assets/images/standard4.jpg',
          'caption': 'Caramel drip cake topped with crushed cookies and Happy Father\'s Day topper. 🤎',
          'likes': '350',
          'comments': '15',
        },
        {
          'image': 'assets/images/standard5.jpg',
          'caption': 'Pastel purple frosted cake with caramel drip and fruit toppings. 💜',
          'likes': '315',
          'comments': '11',
        },
        {
          'image': 'assets/images/standard6.jpg',
          'caption': 'Teal frosted custom dedication cake accented with edible gold leaf. ✨',
          'likes': '675',
          'comments': '9',
        },
        {
          'image': 'assets/images/standard7.jpg',
          'caption': 'Black textured cake with striking floral petal-like decorations and gold leaf accents. ✨',
          'likes': '715',
          'comments': '35',
        },
        {
          'image': 'assets/images/standard10.jpg',
          'caption': 'Romantic red heart-shaped cake with buttercream roses and white pearl sprinkles. ❤️',
          'likes': '950',
          'comments': '68',
        },
        {
          'image': 'assets/images/standard8.jpg',
          'caption': 'Two-tone blue and white cake adorned with delicate pink frosting flowers and gold sprinkles. 🌸',
          'likes': '690',
          'comments': '42',
        },
        {
          'image': 'assets/images/standard9_fixed.jpg',
          'caption': 'Decadent caramel drip cake loaded with crushed cookies and a full cookie topper! 🤎',
          'likes': '820',
          'comments': '55',
        },
        {
          'image': 'assets/images/standard11.jpg',
          'caption': 'Caramel drip cake wrapped in cookie crumbles and topped with golden chocolate coins. 💰',
          'likes': '740',
          'comments': '33',
        },
        {
          'image': 'assets/images/standard12.jpg',
          'caption': 'Ruffled white frosting cake topped with fresh mango slices, chocolate chips, and gold coins. 🥭',
          'likes': '860',
          'comments': '47',
        },
      ],
    },
    {
      'title': 'Customized 1-Tier Cakes',
      'subtitle': 'Tailored Themes & Piping',
      'image': 'assets/images/1st_tier1.jpg',
      'items': [
        {
          'image': 'assets/images/1st_tier1.jpg',
          'caption': 'Bright blue Baby Shark themed birthday cake with colorful confetti and toppers. 🦈💙',
          'likes': '448',
          'comments': '14',
        },
        {
          'image': 'assets/images/1st_tier2.jpg',
          'caption': 'Edgy black and pink Kuromi celebration cake with sweet macarons! 🖤🩷',
          'likes': '620',
          'comments': '38',
        },
        {
          'image': 'assets/images/1st_tier3.jpg',
          'caption': 'Sweet baby blue christening cake with custom baby figurine and stars. ⭐👶',
          'likes': '675',
          'comments': '9',
        },
        {
          'image': 'assets/images/1st_tier4.jpg',
          'caption': 'Adorable Stitch & Cinnamoroll blue pastel celebration cake with custom tag! 💙🧁',
          'likes': '820',
          'comments': '18',
        },
        {
          'image': 'assets/images/1st_tier5.jpg',
          'caption': 'Royal purple sculpted gown cake fit for a princess celebration. 💜👑',
          'likes': '460',
          'comments': '20',
        },
        {
          'image': 'assets/images/1st_tier6.jpg',
          'caption': 'Custom truck topper birthday cake with vibrant red & gold frosting. 🚛🔥',
          'likes': '630',
          'comments': '41',
        },
        {
          'image': 'assets/images/1st_tier7.jpg',
          'caption': 'Whimsical hot air balloon floating over fluffy cloud cake. ☁️🎈',
          'likes': '680',
          'comments': '34',
        },
        {
          'image': 'assets/images/1st_tier8.jpg',
          'caption': 'Pixelated Minecraft block themed adventure cake with custom character topper. 🟩⚔️',
          'likes': '740',
          'comments': '40',
        },
        {
          'image': 'assets/images/1st_tier9.jpg',
          'caption': 'Festive Christmas tree piped green holiday themed cake with angel topper. 🎄✨',
          'likes': '395',
          'comments': '16',
        },
        {
          'image': 'assets/images/1st_tier11.jpg',
          'caption': 'Blue celebration drip cake topped with mini liquor bottles and truffles. 🍾',
          'likes': '410',
          'comments': '17',
        },
        {
          'image': 'assets/images/1st_tier10.jpg',
          'caption': 'Action-packed Paw Patrol themed primary color birthday cake! 🐾🐶',
          'likes': '890',
          'comments': '52',
        },
        {
          'image': 'assets/images/1st_tier12.jpg',
          'caption': 'Red velvet style minimalist cake with heart sprinkles and hand-drawn art. ❤️',
          'likes': '455',
          'comments': '21',
        },
        {
          'image': 'assets/images/1st_tier13.jpg',
          'caption': 'Elegant pink and purple celebration cake with detailed custom borders and candles. 🕯️',
          'likes': '710',
          'comments': '33',
        },
        {
          'image': 'assets/images/1st_tier15.jpg',
          'caption': 'Red and green floral piped cake featuring a grand green angel sculpture. 🕊️',
          'likes': '530',
          'comments': '25',
        },
        {
          'image': 'assets/images/1st_tier14.jpg',
          'caption': 'Vibrant multi-colored floral and swirl piped birthday cake with custom message. 🌸',
          'likes': '799',
          'comments': '59',
        },
        {
          'image': 'assets/images/1st_tier16.jpg',
          'caption': 'Enchanting Harry Potter themed cake complete with sorting hat & wand! ⚡🧙‍♂️',
          'likes': '830',
          'comments': '47',
        },
        {
          'image': 'assets/images/1st_tier17.jpg',
          'caption': 'Pastel purple birthday cake with custom lettering and star sprinkles. ✨',
          'likes': '512',
          'comments': '29',
        },
        {
          'image': 'assets/images/1st_tier19.jpg',
          'caption': 'Number 8 shaped anniversary or birthday cake with rich red and white piping. 🎂',
          'likes': '389',
          'comments': '12',
        },
        {
          'image': 'assets/images/1st_tier25.jpg',
          'caption': 'Fun purple frosted cake featuring a custom COOKY bunny character topper! 💜🐰',
          'likes': '680',
          'comments': '41',
        },
        {
          'image': 'assets/images/1st_tier26.jpg',
          'caption': 'Peach and blue two-tone cake with custom CHA CHA lettering and a delicate pink rose. 🌹',
          'likes': '490',
          'comments': '18',
        },
        {
          'image': 'assets/images/1st_tier27.jpg',
          'caption': 'White drip cake with vibrant purple and pink accents, saying HELLO FAYE. ✨',
          'likes': '715',
          'comments': '33',
        },
        {
          'image': 'assets/images/1st_tier28.jpg',
          'caption': 'Playful pink swirled frosting cake sprinkled with colorful mini hearts. 💖',
          'likes': '550',
          'comments': '22',
        },
        {
          'image': 'assets/images/1st_tier29.jpg',
          'caption': 'Striking red heart-shaped cake dedicated to a HAPPY MONTHSARY. ❤️',
          'likes': '820',
          'comments': '48',
        },
      ],
    },
    {
      'title': 'Customized 2-Tier & Up',
      'subtitle': 'Grand Multi-Tier Masterpieces',
      'image': 'assets/images/2nd_tier1.jpg',
      'items': [
        {
          'image': 'assets/images/2nd_tier2.jpg',
          'caption': 'Two-tier white and gold christening cake with blessed cross and custom lettering. 🕊️✨',
          'likes': '950',
          'comments': '48',
        },
        {
          'image': 'assets/images/2nd_tier1.jpg',
          'caption': 'Action-packed multi-tiered custom character birthday cake masterpiece! 🐾🎂',
          'likes': '890',
          'comments': '52',
        },
        {
          'image': 'assets/images/2nd_tier3.jpg',
          'caption': 'Vibrant blue Baby Shark themed two-tier celebration cake with aquatic accents. 🦈🌊',
          'likes': '880',
          'comments': '42',
        },
        {
          'image': 'assets/images/3rd_tier1.jpg',
          'caption': 'Three-tier pastel pink Peppa Pig birthday wonderland cake with house details. 🐷🏡',
          'likes': '710',
          'comments': '33',
        },
      ],
    },
    {
      'title': 'Mini Cakes & Cupcakes',
      'subtitle': 'Small-Batch Sweet Drops',
      'image': 'assets/images/cake&cupcake1.jpg',
      'items': [
        {
          'image': 'assets/images/cake&cupcake1.jpg',
          'caption': 'Colorful letter-topper celebration cake surrounded by matching golden cupcakes! 🔤🧁',
          'likes': '610',
          'comments': '31',
        },
        {
          'image': 'assets/images/cake&cupcake2.jpg',
          'caption': 'Custom blue celebration mini cake surrounded by rich dark chocolate cupcakes. 💙',
          'likes': '540',
          'comments': '22',
        },
        {
          'image': 'assets/images/cake&cupcake3.jpg',
          'caption': 'Pastel purple frosted mini cake paired with matching swirl cupcakes. 💜',
          'likes': '485',
          'comments': '19',
        },
        {
          'image': 'assets/images/cake&cupcake4.jpg',
          'caption': 'Classic white bento mini cake accompanied by pink buttercream cupcakes. 🌸',
          'likes': '590',
          'comments': '27',
        },
        {
          'image': 'assets/images/cake&cupcake5.jpg',
          'caption': 'Brown frosted cake topped with a smiling fondant character and blue rosettes, paired with blue frosted cupcakes. 💙',
          'likes': '640',
          'comments': '29',
        },
        {
          'image': 'assets/images/cake&cupcake6.jpg',
          'caption': 'Vibrant purple mini cake and cupcakes featuring a rolled diploma and graduation theme! 🎓💜',
          'likes': '710',
          'comments': '35',
        },
        {
          'image': 'assets/images/cake&cupcake7.jpg',
          'caption': 'Red heart-shaped cake reading HAPPY MONTHSARY paired with floral piped cupcakes. ❤️',
          'likes': '820',
          'comments': '44',
        },
        {
          'image': 'assets/images/cake&cupcake9.jpg',
          'caption': 'Twin holiday mini cakes adorned with pink poinsettias and MERRY CHRISTMAS lettering, served with festive cupcakes. 🎄',
          'likes': '910',
          'comments': '52',
        },
        {
          'image': 'assets/images/cake&cupcake10.jpg',
          'caption': 'Rustic nut-crusted carrot cake reading HABADU flanked by two matching cupcakes. 🥕',
          'likes': '680',
          'comments': '31',
        },
      ],
    },
    {
      'title': 'Cupcakes',
      'subtitle': 'Bite-Sized Indulgence',
      'image': 'assets/images/cupcake5.jpg',
      'items': [
        {
          'image': 'assets/images/cupcake1.jpg',
          'caption': 'Happy Mother\'s Day themed cupcakes with pink and purple frosting and gold toppers. 🌸',
          'likes': '420',
          'comments': '15',
        },
        {
          'image': 'assets/images/cupcake2.jpg',
          'caption': 'Elegant Mother\'s Day half-dozen with purple rosette and pink swirl buttercream. 💜',
          'likes': '385',
          'comments': '22',
        },
        {
          'image': 'assets/images/cupcake3.jpg',
          'caption': 'Four beautifully piped red and white buttercream rose cupcakes. 🌹',
          'likes': '512',
          'comments': '34',
        },
        {
          'image': 'assets/images/cupcake4.jpg',
          'caption': 'Magical Harry Potter themed cupcakes featuring the Sorting Hat and Golden Snitch! ⚡🧙‍♂️',
          'likes': '476',
          'comments': '18',
        },
        {
          'image': 'assets/images/cupcake5.jpg',
          'caption': 'A dozen vibrant blue and white swirl frosted cupcakes with gold sprinkles. 💙✨',
          'likes': '610',
          'comments': '41',
        },
        {
          'image': 'assets/images/cupcake6.jpg',
          'caption': 'Teal and purple galaxy-inspired swirl cupcakes in a dozen box. 🌌',
          'likes': '395',
          'comments': '12',
        },
        {
          'image': 'assets/images/cupcake7.jpg',
          'caption': 'Adorable pink and white animal-themed cupcakes, perfect for kids\' parties! 🐶💖',
          'likes': '550',
          'comments': '28',
        },
        {
          'image': 'assets/images/cupcake8.jpg',
          'caption': 'Striking red and yellow rose piped buttercream cupcakes. ❤️💛',
          'likes': '680',
          'comments': '55',
        },
        {
          'image': 'assets/images/cupcake9.jpg',
          'caption': 'Six elegant pink and purple swirled cupcakes with gold pearl sprinkles. ✨',
          'likes': '430',
          'comments': '19',
        },
        {
          'image': 'assets/images/cupcake10.jpg',
          'caption': 'Mint green and pastel yellow floral buttercream cupcakes. 🌿💛',
          'likes': '720',
          'comments': '47',
        },
        {
          'image': 'assets/images/cupcake11.jpg',
          'caption': 'Six bold red and white swirl frosted cupcakes. ❤️🤍',
          'likes': '590',
          'comments': '33',
        },
        {
          'image': 'assets/images/cupcake12.jpg',
          'caption': 'A grand box of 24 elegant purple rosette cupcakes with delicate flower accents. 💜🌸',
          'likes': '645',
          'comments': '38',
        },
      ],
    },
  ];


  List<Map<String, dynamic>> get _displayCategories {
    return _categories;
  }

  void _openCategoryModal(BuildContext context, Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 950, maxHeight: 750),
          decoration: BoxDecoration(
            color: AppColors.bgPastelPink,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.bgPastelPink, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(60, 34, 22, 0.25),
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.bgPastelPink,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: AppColors.bgPastelPink)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category['title'],
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGarnet,
                          ),
                        ),
                        Text(
                          category['subtitle'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDarkBerry,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textDarkBerry, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: (category['items'] as List).length,
                    itemBuilder: (context, index) {
                      final item = category['items'][index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => InstagramPostModal(item: item),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.bgPastelPink),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(60, 34, 22, 0.05),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.asset(
                                    item['image'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.favorite, color: AppColors.brandRed, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          item['likes'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDarkBerry,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['caption'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textDarkBerry),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flutterView = View.of(context);
    final double screenWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    final bool isMobile = screenWidth < 768;

    final categories = _displayCategories;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60),
      color: Colors.transparent,
      child: Column(
        children: [
          // Header Text
          Text(
            'OUR GALLERY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppColors.brandRed,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: Text(
              'A Glimpse of Our Creations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: isMobile ? 28 : 42,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGarnet,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: Text(
              'Take a look at some of our favorite moments, custom cakes and cozy treats.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDarkBerry,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Gallery Category Cards (5 Images)
          SizedBox(
            height: isMobile ? 280 : 340,
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: isMobile ? 16 : 24),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _GalleryCategoryCard(
                  category: category,
                  width: isMobile ? 180 : 220,
                  onTap: () => _openCategoryModal(context, category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final double width;

  const _GalleryCategoryCard({
    required this.category,
    required this.onTap,
    required this.width,
  });

  @override
  State<_GalleryCategoryCard> createState() => _GalleryCategoryCardState();
}

class _GalleryCategoryCardState extends State<_GalleryCategoryCard> {
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(60, 34, 22, _isHovered ? 0.2 : 0.0),
                blurRadius: _isHovered ? 20 : 0,
                offset: Offset(0, _isHovered ? 12 : 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.category['image']!,
                  fit: BoxFit.cover,
                ),
                // Gradient overlay so text is readable
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.category['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.category['subtitle'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Hover overlay (View Collection button style)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.collections, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
}

