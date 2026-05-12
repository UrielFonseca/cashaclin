/// Modelo de datos representativo de un Producto.
/// Define la estructura técnica de los artículos del catálogo.
class Product {
  final String id; // Identificador único del documento (MongoDB _id).
  String name; // Nombre comercial del producto.
  String sku; // Clave de inventario generada automáticamente.
  String category; // Categoría operativa (Limpieza, Lavado, etc.).
  String image; // URL de la imagen hospedada en el servidor.
  String description; // Descripción técnica o comercial del artículo.
  double price; // Valor monetario unitario.
  int stock; // Cantidad física disponible en el almacén.

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

  /// Mapea un objeto JSON proveniente de la API o base de datos a una instancia de Product.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      // Se normaliza el identificador para aceptar tanto 'id' como '_id'.
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

  /// Convierte la instancia del objeto a un Mapa para su envío serializado mediante la API.
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
