import '../models/product.dart';

final List<Product> mockProducts = [
  // --- COOKIES (1 to 5) ---
  const Product(
    id: 1,
    order: 1,
    name: 'Twix Chocolate',
    category: 'cookies',
    price: 260.0,
    priceBox6: 390.0,
    servingSize: 'Box of 4',
    description:
        'Golden cookie filled with spiced caramel and milk chocolate inspired by classic Twix chocolate bars.',
    imgSrc: 'assets/images/biscoff.jpg',
    icon: '🍯',
  ),
  const Product(
    id: 2,
    order: 2,
    name: 'Snicker-Doodle Hug',
    category: 'cookies',
    price: 260.0,
    priceBox6: 390.0,
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
    price: 260.0,
    priceBox6: 390.0,
    servingSize: 'Box of 4',
    description:
        'Intense 70% dark Belgian cocoa dough packed with molten dark chocolate morsels and finished with flaky sea salt.',
    imgSrc: 'assets/images/dark choco.jpg',
    icon: '🍫',
  ),
  const Product(
    id: 5,
    order: 5,
    name: 'Belgian Choco Chip',
    category: 'cookies',
    price: 260.0,
    priceBox6: 390.0,
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
    price: 360.0,
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
    price: 360.0,
    servingSize: 'Box of 8 pcs',
    description:
        'Decadent, crinkle-top double fudge brownie squares baked with rich Hershey’s Special Dark Kisses melted throughout.',
    imgSrc: 'assets/images/brownies1.jpg',
    icon: '🟫',
  ),
  // --- CAKE LOAFS (8 to 9) ---
  const Product(
    id: 11,
    order: 8,
    name: 'Carrot Cake Loaf',
    category: 'cake loafs',
    price: 350.0,
    servingSize: '1 Loaf',
    description:
        'Moist and spiced carrot cake loaf, packed with freshly grated carrots, walnuts, and topped with signature cream cheese frosting.',
    imgSrc: 'assets/images/carrot_cake_loaf.jpg',
    icon: '🥕',
  ),
  const Product(
    id: 12,
    order: 9,
    name: 'Banana Cake Loaf Overload',
    category: 'cake loafs',
    price: 300.0,
    servingSize: '1 Loaf',
    description:
        'Classic soft and fluffy banana cake loaf made from overripe bananas, topped with a generous sprinkle of chocolate chips.',
    imgSrc: 'assets/images/banana_cake_loaf.jpg',
    icon: '🍌',
  ),

  // --- LAYER CAKES (10 to 12) ---
  const Product(
    id: 8,
    order: 10,
    name: 'Caramel Cookie Drip Cake',
    category: 'cakes',
    price: 800.0, // Standard cake base starting price
    servingSize: null,
    description:
        'Decadent caramel drip cake loaded with crushed cookies and a full cookie topper! 🤎',
    imgSrc: 'assets/images/standard9_fixed.jpg',
    icon: '🤎',
  ),
  const Product(
    id: 9,
    order: 11,
    name: 'Whimsical Hot Air Balloon Cloud Cake',
    category: 'cakes',
    price: 1450.0, // 1 Tier starting price
    servingSize: null,
    description:
        'Whimsical customized 1-tier celebration cake featuring a hot air balloon floating over fluffy clouds. ☁️🎈',
    imgSrc: 'assets/images/1st_tier7.jpg',
    icon: '🎈',
  ),
  const Product(
    id: 10,
    order: 12,
    name: 'Action-Packed Character Masterpiece',
    category: 'cakes',
    price: 2500.0, // 2 Tier starting price
    servingSize: null,
    description:
        'Action-packed multi-tiered custom character birthday cake masterpiece!🐾🎂',
    imgSrc: 'assets/images/2nd_tier1.jpg',
    icon: '🐾',
  ),
];
