class Product {
  final int id;
  final String name;
  final String category;
  final double price; // Base price (Box of 4 for cookies)
  final double? priceBox6; // Price for Box of 6 (cookies only)
  final String description;
  final String imgSrc;
  final String? servingSize;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.priceBox6,
    required this.description,
    required this.imgSrc,
    this.servingSize,
  });
}