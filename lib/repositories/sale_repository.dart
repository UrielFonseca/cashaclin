import '../services/api_service.dart';

class SaleRepository {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getSales() async {
    try {
      final List<dynamic> data = await _apiService.get('/sales');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMySales() async {
    try {
      final List<dynamic> data = await _apiService.get('/sales/my');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  Future<void> createSale(Map<String, dynamic> saleData) async {
    await _apiService.post('/sales', saleData);
  }

  Future<void> updateSaleStatus(String id, String status) async {
    await _apiService.put('/sales/$id/status', {'status': status});
  }

  // Nueva función para el flujo de negociación
  Future<void> negotiateSale(String id, {double? total, String? status, String? message}) async {
    await _apiService.put('/sales/$id/negotiate', {
      if (total != null) 'total': total,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
    });
  }
}
