import '../services/api_service.dart';
import '../Pantallas/models/product_model.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  // Obtener productos directamente de la API
  Future<List<Product>> getProducts() async {
    try {
      final List<dynamic> data = await _apiService.get('/products');
      return data.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      throw Exception("Error al conectar con la API: $e");
    }
  }

  Future<void> addProduct(Product product) async {
    await _apiService.post('/products', product.toMap());
  }

  Future<void> updateStock(String id, int newStock) async {
    await _apiService.post('/products/$id/stock', {'stock': newStock});
  }

  Future<void> deleteProduct(String id) async {
    // Asumiendo que el ApiService tiene un método delete o enviando vía post según tu backend
    await _apiService.post('/products/$id/delete', {});
  }
}
