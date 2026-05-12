import '../services/api_service.dart';
import '../Pantallas/models/product_model.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  Future<List<Product>> getProducts() async {
    try {
      final List<dynamic> data = await _apiService.get('/products');
      return data.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addProduct(Product product) async {
    await _apiService.post('/products', product.toMap());
  }

  Future<void> updateProduct(String id, Product product) async {
    // Usamos PUT para actualizar el documento existente por su ID
    await _apiService.put('/products/$id', product.toMap());
  }

  Future<void> updateStock(String id, int newStock) async {
    await _apiService.post('/products/$id/stock', {'stock': newStock});
  }

  Future<void> deleteProduct(String id) async {
    // Usamos el método DELETE de la API
    await _apiService.delete('/products/$id');
  }
}
