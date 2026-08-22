import '../models/product.dart';

final List<Product> mockProducts = [
  // --- COOKIES (1 to 5) ---
  const Product(
    id: 1,
    order: 1,
    name: 'Biscoff Nocciola Swirl',
    category: 'cookies',
    price: 260.0,
    priceBox6: 375.0,
    servingSize: 'Box of 4',
    description:
        'Golden cookie filled with spiced Lotus Biscoff cookie butter spread and swirled with rich Nutella hazelnut cocoa.',
    imgSrc: 'assets/images/biscoff.jpg',
    icon: '🍯',
  ),
  const Product(
    id: 2,
    order: 2,
    name: 'Snicker-Doodle Hug',
    category: 'cookies',
    price: 240.0,
    priceBox6: 350.0,
    servingSize: 'Box of 4',
    description:
        'Soft-baked cookie studded with roasted peanuts, gooey nougat caramel pockets, and creamy melted milk chocolate.',
    imgSrc: 'assets/images/snickers.jpg',
    icon: '🥜',
  ),
  const Product(
    id: 3,
    order: 3,
    name: 'Dark Chocolate Noir',
    category: 'cookies',
    price: 220.0,
    priceBox6: 320.0,
    servingSize: 'Box of 4',
    description:
        'Intense 70% dark Belgian cocoa dough packed with molten dark chocolate morsels and finished with flaky sea salt.',
    imgSrc: 'assets/images/dark choco.jpg',
    icon: '🍫',
  ),
  const Product(
    id: 4,
    order: 4,
    name: 'Red Velvet Kiss Blossom',
    category: 'cookies',
    price: 230.0,
    priceBox6: 330.0,
    servingSize: 'Box of 4',
    description:
        'Vibrant crimson cocoa cookie with a gooey cream cheese molten center and studded with premium white chocolate chips.',
    imgSrc: 'assets/images/redvelvet.jpg',
    icon: '❤️',
  ),
  const Product(
    id: 5,
    order: 5,
    name: 'Belgian Choco Chip',
    category: 'cookies',
    price: 200.0,
    priceBox6: 290.0,
    servingSize: 'Box of 4',
    description:
        'Our signature browned-butter cookie with golden, chewy edges and loaded with molten semi-sweet chocolate pools.',
    imgSrc: 'assets/images/og.jpg',
    icon: '🍪',
  ),

  // --- BROWNIES (6 to 7) ---
  const Product(
    id: 6,
    order: 6,
    name: "Hershey's Almond Cloud Squares",
    category: 'brownies',
    price: 380.0,
    servingSize: 'Box of 8 pcs',
    description:
        'Ultra-fudgy dark cocoa brownie squares topped with crunchy roasted whole almonds and a smooth Hershey’s chocolate drizzle.',
    imgSrc: 'assets/images/brownies.jpg',
    icon: '☁️',
  ),
  const Product(
    id: 7,
    order: 7,
    name: 'Dark Kissed Melt Bites',
    category: 'brownies',
    price: 390.0,
    servingSize: 'Box of 8 pcs',
    description:
        'Decadent, crinkle-top double fudge brownie squares baked with rich Hershey’s Special Dark Kisses melted throughout.',
    imgSrc: 'assets/images/brownies1.jpg',
    icon: '🟫',
  ),

  // --- LAYER CAKES (8 to 10) ---
  const Product(
    id: 8,
    order: 8,
    name: 'Pure Decadence Cocoa Fudge',
    category: 'cakes',
    price: 850.0,
    servingSize: null,
    description:
        'All-chocolate indulgence with deep cocoa sponge layers, rich dark fudge filling, and vintage piped chocolate buttercream borders.',
    imgSrc: 'assets/images/cake4.jpg',
    icon: '🎂',
  ),
  const Product(
    id: 9,
    order: 9,
    name: 'Vanilla Sky Cerulean Dream',
    category: 'cakes',
    price: 880.0,
    servingSize: null,
    description:
        'Playful sky-blue celebration cake featuring handcrafted 3D edible fondant character toppers, cloud piping, and vanilla buttercream swirls.',
    imgSrc: 'assets/images/cake2_.jpg',
    icon: '🩵',
  ),
  const Product(
    id: 10,
    order: 10,
    name: 'Lavender Noir Velvet',
    category: 'cakes',
    price: 950.0,
    servingSize: null,
    description:
        'Stunning 3D sculpted doll celebration cake with dramatic tiered cascading purple buttercream ruffles and floral petal piping.',
    imgSrc: 'assets/images/cake1.jpg',
    icon: '💜',
  ),
];
