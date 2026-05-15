import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/*
  Servicio de Comunicación API:
  Gestiona todas las peticiones HTTP hacia el servidor central en producción.
  Encapsula la lógica de cabeceras, autenticación JWT y manejo de respuestas.
*/
class ApiService {
  /// URL base del servidor Backend alojado en Render.
  static String get baseUrl => "https://cashaclin.onrender.com/api";

  /// Genera las cabeceras estándar incluyendo el token de autorización si existe.
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  /// Realiza una petición GET para obtener recursos del servidor.
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  /// Realiza una petición POST para la creación de nuevos registros.
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  /// Realiza una petición PUT para la actualización de registros existentes.
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  /// Realiza una petición DELETE para la eliminación de recursos.
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  /// Centraliza el procesamiento de respuestas y gestión de errores de red.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Error operativo del servidor: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
