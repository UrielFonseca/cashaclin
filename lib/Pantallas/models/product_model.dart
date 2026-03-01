class Product {
  final String id;
  String name;
  String sku;
  String category;
  String image;
  String description;
  double price;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.image,
    this.description = '',
    this.price = 0.0,
    required this.stock,
  });
}
