import '../services/api_service.dart';
import '../Pantallas/models/product_model.dart';

/// Repositorio de Productos:
/// Actúa como mediador entre la interfaz de usuario y el servicio de API.
/// Centraliza todas las operaciones relacionadas con el catálogo de artículos.
class ProductRepository {
  final ApiService _apiService = ApiService();

  /// Recupera el listado completo de productos desde el servidor.
  Future<List<Product>> getProducts() async {
    try {
      final List<dynamic> data = await _apiService.get('/products');
      // Mapeo de la respuesta JSON a una lista de objetos de tipo Product.
      return data.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      // Retorna una lista vacía en caso de fallo de red o error de servidor.
      return [];
    }
  }

  /// Registra un nuevo producto en la base de datos centralizada.
  Future<void> addProduct(Product product) async {
    await _apiService.post('/products', product.toMap());
  }

  /// Actualiza la información de un producto existente mediante su identificador único.
  Future<void> updateProduct(String id, Product product) async {
    // Utiliza el método HTTP PUT para realizar una actualización parcial o total del recurso.
    await _apiService.put('/products/$id', product.toMap());
  }

  /// Modifica únicamente el nivel de existencias de un artículo específico.
  Future<void> updateStock(String id, int newStock) async {
    await _apiService.post('/products/$id/stock', {'stock': newStock});
  }

  /// Elimina un producto del catálogo del sistema.
  Future<void> deleteProduct(String id) async {
    // Realiza una petición de eliminación definitiva al servidor.
    await _apiService.delete('/products/$id');
  }
}
