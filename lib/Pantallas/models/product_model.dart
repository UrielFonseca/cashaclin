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

  // 🔹 Ajustado para que MongoDB y Flutter se entiendan
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      // Si la API manda _id (Mongo) o id, lo capturamos correctamente
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      category: map['category'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'image': image,
      'description': description,
      'price': price,
      'stock': stock,
    };
  }
}
