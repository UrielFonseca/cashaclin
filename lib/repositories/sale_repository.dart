import '../services/api_service.dart';

class SaleRepository {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getSales() async {
    try {
      final List<dynamic> data = await _apiService.get('/sales');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception("Error al obtener ventas: $e");
    }
  }

  Future<void> createSale(Map<String, dynamic> saleData) async {
    await _apiService.post('/sales', saleData);
  }
}
