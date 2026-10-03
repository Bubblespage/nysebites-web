import 'dart:typed_data';

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
  final Uint8List? customImageBytes;

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
    this.customImageBytes,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
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

  Product copyWith({
    dynamic id,
    String? name,
    String? category,
    double? price,
    double? priceBox6,
    String? servingSize,
    String? description,
    String? imgSrc,
    String? icon,
    int? stock,
    bool? active,
    int? order,
    Uint8List? customImageBytes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      priceBox6: priceBox6 ?? this.priceBox6,
      servingSize: servingSize ?? this.servingSize,
      description: description ?? this.description,
      imgSrc: imgSrc ?? this.imgSrc,
      icon: icon ?? this.icon,
      stock: stock ?? this.stock,
      active: active ?? this.active,
      order: order ?? this.order,
      customImageBytes: customImageBytes ?? this.customImageBytes,
    );
  }
}
