class Product {
  final dynamic id;
  final String name;
  final String category;
  final double price;
  final double? priceBox6;
  final String? servingSize;
  final String description;
  final String imgSrc;
  final String icon;
  final int stock;
  final bool active;
  final int order;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.priceBox6,
    this.servingSize,
    required this.description,
    required this.imgSrc,
    this.icon = '🍪',
    this.stock = 20,
    this.active = true,
    this.order = 99,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      order: data['order'] is int
          ? data['order']
          : (int.tryParse(data['order']?.toString() ?? '') ??
                99), // Defaults to end if missing
      name: data['name'] ?? '',
      category: data['category'] ?? 'cookies',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      priceBox6: (data['priceBox6'] as num?)?.toDouble(),
      servingSize: data['servingSize'],
      description: data['description'] ?? '',
      imgSrc: data['imgSrc'] ?? 'assets/images/og.jpg',
      icon: data['icon'] ?? '🍪',
      active: data['active'] ?? true,
    );
  }
}
