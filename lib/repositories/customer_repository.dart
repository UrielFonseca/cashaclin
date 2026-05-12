import '../services/api_service.dart';

class CustomerRepository {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final List<dynamic> data = await _apiService.get('/customers');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  Future<void> addCustomer(Map<String, dynamic> customer) async {
    await _apiService.post('/customers', customer);
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> customer) async {
    await _apiService.put('/customers/$id', customer);
  }

  Future<void> deleteCustomer(String id) async {
    await _apiService.delete('/customers/$id');
  }
}
