import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Servicio encargado de la comunicación con la API REST.
/// Centraliza las peticiones HTTP y la gestión de cabeceras de seguridad.
class ApiService {
  /// Determina la URL base dependiendo de si la ejecución es en plataforma Web o Móvil.
  static String get baseUrl {
    if (kIsWeb) return "https://cashaclin.onrender.com/api";
    return "https://cashaclin.onrender.com/api";
  }

  /// Construye las cabeceras de la petición, incluyendo el token JWT si está disponible.
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  /// Realiza una petición GET al endpoint especificado.
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  /// Realiza una petición POST enviando un cuerpo en formato JSON.
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  /// Realiza una petición PUT para actualización de recursos.
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  /// Realiza una petición DELETE para eliminación de recursos.
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  /// Procesa la respuesta del servidor y gestiona los códigos de estado HTTP.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Error del servidor: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
