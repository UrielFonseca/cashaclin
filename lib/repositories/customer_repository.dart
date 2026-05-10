import '../services/api_service.dart';

class CustomerRepository {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final List<dynamic> data = await _apiService.get('/customers');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception("Error al obtener clientes: $e");
    }
  }

  Future<void> addCustomer(Map<String, dynamic> customer) async {
    await _apiService.post('/customers', customer);
  }
}
