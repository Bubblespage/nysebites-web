import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OvenGallerySection extends StatefulWidget {
  const OvenGallerySection({super.key});

  @override
  State<OvenGallerySection> createState() => _OvenGallerySectionState();
}

class _OvenGallerySectionState extends State<OvenGallerySection> {
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Standard Cakes',
      'subtitle': 'Classic & Elegant (6 Designs)',
      'image': 'assets/images/standard1.jpg',
      'items': [
        {
          'image': 'assets/images/standard1.jpg',
          'caption':
              'Vibrant pink Happy Birthday topper with gorgeous buttercream rose swirls. 🌹✨',
          'likes': '940',
          'comments': '65',
        },
        {
          'image': 'assets/images/standard2.jpg',
          'caption':
              'Classic red and white piped celebration cake with festive ribbon bows. 🎀',
          'likes': '410',
          'comments': '18',
        },
        {
          'image': 'assets/images/standard3.jpg',
          'caption':
              'Lush green vintage piped cake adorned with delicate white daisies. 🌼🌿',
          'likes': '799',
          'comments': '59',
        },
        {
          'image': 'assets/images/standard4.jpg',
          'caption':
              'Caramel drip cake topped with crushed cookies and Happy Father\'s Day topper. 🤎',
          'likes': '350',
          'comments': '15',
        },
        {
          'image': 'assets/images/standard5.jpg',
          'caption':
              'Pastel purple frosted cake with caramel drip and fruit toppings. 💜',
          'likes': '315',
          'comments': '11',
        },
        {
          'image': 'assets/images/standard6.jpg',
          'caption':
              'Teal frosted custom dedication cake accented with edible gold leaf. ✨',
          'likes': '675',
          'comments': '9',
        },
      ],
    },
    {
      'title': 'Customized 1-Tier Cakes',
      'subtitle': 'Tailored Themes & Piping (19 Designs)',
      'image': 'assets/images/1st_tier1.jpg',
      'items': [
        {
          'image': 'assets/images/1st_tier1.jpg',
          'caption':
              'Bright blue Baby Shark themed birthday cake with colorful confetti and toppers. 🦈💙',
          'likes': '448',
          'comments': '14',
        },
        {
          'image': 'assets/images/1st_tier2.jpg',
          'caption':
              'Edgy black and pink Kuromi celebration cake with sweet macarons! 🖤🩷',
          'likes': '620',
          'comments': '38',
        },
        {
          'image': 'assets/images/1st_tier3.jpg',
          'caption':
              'Sweet baby blue christening cake with custom baby figurine and stars. ⭐👶',
          'likes': '675',
          'comments': '9',
        },
        {
          'image': 'assets/images/1st_tier4.jpg',
          'caption':
              'Adorable Stitch & Cinnamoroll blue pastel celebration cake with custom tag! 💙🧁',
          'likes': '820',
          'comments': '18',
        },
        {
          'image': 'assets/images/1st_tier5.jpg',
          'caption':
              'Royal purple sculpted gown cake fit for a princess celebration. 💜👑',
          'likes': '460',
          'comments': '20',
        },
        {
          'image': 'assets/images/1st_tier6.jpg',
          'caption':
              'Custom truck topper birthday cake with vibrant red & gold frosting. 🚛🔥',
          'likes': '630',
          'comments': '41',
        },
        {
          'image': 'assets/images/1st_tier7.jpg',
          'caption':
              'Whimsical hot air balloon floating over fluffy cloud cake. ☁️🎈',
          'likes': '680',
          'comments': '34',
        },
        {
          'image': 'assets/images/1st_tier8.jpg',
          'caption':
              'Pixelated Minecraft block themed adventure cake with custom character topper. 🟩⚔️',
          'likes': '740',
          'comments': '40',
        },
        {
          'image': 'assets/images/1st_tier9.jpg',
          'caption':
              'Festive Christmas tree piped green holiday themed cake with angel topper. 🎄✨',
          'likes': '395',
          'comments': '16',
        },

        {
          'image': 'assets/images/1st_tier11.jpg',
          'caption':
              'Blue celebration drip cake topped with mini liquor bottles and truffles. 🍾',
          'likes': '410',
          'comments': '17',
        },
        {
          'image': 'assets/images/1st_tier10.jpg',
          'caption':
              'Action-packed Paw Patrol themed primary color birthday cake! 🐾🐶',
          'likes': '890',
          'comments': '52',
        },
        {
          'image': 'assets/images/1st_tier12.jpg',
          'caption':
              'Red velvet style minimalist cake with heart sprinkles and hand-drawn art. ❤️',
          'likes': '455',
          'comments': '21',
        },
        {
          'image': 'assets/images/1st_tier13.jpg',
          'caption':
              'Elegant pink and purple celebration cake with detailed custom borders and candles. 🕯️',
          'likes': '710',
          'comments': '33',
        },
        {
          'image': 'assets/images/1st_tier15.jpg',
          'caption':
              'Red and green floral piped cake featuring a grand green angel sculpture. 🕊️',
          'likes': '530',
          'comments': '25',
        },
        {
          'image': 'assets/images/1st_tier14.jpg',
          'caption':
              'Vibrant multi-colored floral and swirl piped birthday cake with custom message. 🌸',
          'likes': '799',
          'comments': '59',
        },

        {
          'image': 'assets/images/1st_tier16.jpg',
          'caption':
              'Enchanting Harry Potter themed cake complete with sorting hat & wand! ⚡🧙‍♂️',
          'likes': '830',
          'comments': '47',
        },
        {
          'image': 'assets/images/1st_tier17.jpg',
          'caption':
              'Pastel purple birthday cake with custom lettering and star sprinkles. ✨',
          'likes': '512',
          'comments': '29',
        },
        {
          'image': 'assets/images/1st_tier18.jpg',
          'caption':
              'Decadent chocolate overload cake stacked with bars and truffles. 🍫🤎',
          'likes': '515',
          'comments': '24',
        },
        {
          'image': 'assets/images/1st_tier19.jpg',
          'caption':
              'Number 8 shaped anniversary or birthday cake with rich red and white piping. 🎂',
          'likes': '389',
          'comments': '12',
        },
      ],
    },
    {
      'title': 'Customized 2-Tier & Up',
      'subtitle': 'Grand Multi-Tier Masterpieces (4 Designs)',
      'image': 'assets/images/2nd_tier1.jpg',
      'items': [
        {
          'image': 'assets/images/2nd_tier2.jpg',
          'caption':
              'Two-tier white and gold christening cake with blessed cross and custom lettering. 🕊️✨',
          'likes': '950',
          'comments': '48',
        },
        {
          'image': 'assets/images/2nd_tier1.jpg',
          'caption':
              'Action-packed multi-tiered custom character birthday cake masterpiece! 🐾🎂',
          'likes': '890',
          'comments': '52',
        },
        {
          'image': 'assets/images/2nd_tier3.jpg',
          'caption':
              'Vibrant blue Baby Shark themed two-tier celebration cake with aquatic accents. 🦈🌊',
          'likes': '880',
          'comments': '42',
        },
        {
          'image': 'assets/images/3rd_tier1.jpg',
          'caption':
              'Three-tier pastel pink Peppa Pig birthday wonderland cake with house details. 🐷🏡',
          'likes': '710',
          'comments': '33',
        },
      ],
    },
    {
      'title': 'Mini Cakes & Cupcakes',
      'subtitle': 'Small-Batch Sweet Drops (4 Designs)',
      'image': 'assets/images/cake&cupcake1.jpg',
      'items': [
        {
          'image': 'assets/images/cake&cupcake1.jpg',
          'caption':
              'Colorful letter-topper celebration cake surrounded by matching golden cupcakes! 🔤🧁',
          'likes': '610',
          'comments': '31',
        },
        {
          'image': 'assets/images/cake&cupcake2.jpg',
          'caption':
              'Custom blue celebration mini cake surrounded by rich dark chocolate cupcakes. 💙',
          'likes': '540',
          'comments': '22',
        },
        {
          'image': 'assets/images/cake&cupcake3.jpg',
          'caption':
              'Pastel purple frosted mini cake paired with matching swirl cupcakes. 💜',
          'likes': '485',
          'comments': '19',
        },
        {
          'image': 'assets/images/cake&cupcake4.jpg',
          'caption':
              'Classic white bento mini cake accompanied by pink buttercream cupcakes. 🌸',
          'likes': '590',
          'comments': '27',
        },
      ],
    },
  ];

  void _openCategoryModal(BuildContext context, Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 950, maxHeight: 750),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF2E9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: Color(0xFFEFE4D6))),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E1B10),
                          ),
                        ),
                        Text(
                          category['subtitle'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF756256),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF756256),
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: (category['items'] as List).length,
                    itemBuilder: (context, index) {
                      final item = category['items'][index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5D5C5)),
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
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.asset(
                                  item['image'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.redAccent,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['likes'],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E1B10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['caption'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF756256),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
            'Explore our cake tiers and daily treat collections. Click any category to view all designs!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF756256), fontSize: 13.5),
          ),
          const SizedBox(height: 28),
          Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _categories.map((category) {
                return SizedBox(
                  width: 240,
                  child: _HoverableCategoryCard(
                    category: category,
                    onTap: () => _openCategoryModal(context, category),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableCategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const _HoverableCategoryCard({required this.category, required this.onTap});

  @override
  State<_HoverableCategoryCard> createState() => _HoverableCategoryCardState();
}

class _HoverableCategoryCardState extends State<_HoverableCategoryCard> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1,
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
                        color: Color.fromRGBO(
                          60,
                          34,
                          22,
                          _isHovered ? 0.18 : 0.08,
                        ),
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
                        Image.asset(
                          widget.category['image']!,
                          fit: BoxFit.cover,
                        ),
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
                            padding: const EdgeInsets.all(20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.collections_rounded,
                                  color: Colors.white,
                                  size: 44,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'View Collection ✨',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
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
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.category['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E1B10),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.category['subtitle']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF756256),
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
