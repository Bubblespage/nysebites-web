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
    id: 4,
    order: 4,
    name: 'KitKat Chocolate',
    category: 'cookies',
    price: 260.0,
    priceBox6: 390.0,
    servingSize: 'Box of 4',
    description:
        'Crispy wafer-infused cocoa cookie with a smooth milk chocolate shell and creamy center.',
    imgSrc: 'assets/images/redvelvet.jpg',
    icon: '❤️',
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

  // --- LAYER CAKES (8 to 10) ---
  const Product(
    id: 8,
    order: 8,
    name: 'Pure Decadance Cocoa Fudge',
    category: 'cakes',
    price: 800.0, // Standard cake base starting price
    servingSize: null,
    description:
        'Choose dimensions, choice of chocolate, vanilla, and icing styles.',
    imgSrc: 'assets/images/cake4.jpg',
    icon: '🎂',
  ),
  const Product(
    id: 9,
    order: 9,
    name: 'Vanilla Sky Cerulean Dream',
    category: 'cakes',
    price: 1450.0, // 1 Tier starting price
    servingSize: null,
    description:
        'Customized 1-tier celebration cake featuring 3D design elements and custom printable flavor bases.',
    imgSrc: 'assets/images/cake2_.jpg',
    icon: '🩵',
  ),
  const Product(
    id: 10,
    order: 10,
    name: 'Lavender Noir Velvet',
    category: 'cakes',
    price: 2500.0, // 2 Tier starting price
    servingSize: null,
    description:
        'Customized 2-tier celebration cake with dramatic tiered cascading buttercream ruffles (Requires 2 weeks reservation notice).',
    imgSrc: 'assets/images/cake1.jpg',
    icon: '💜',
  ),
];
