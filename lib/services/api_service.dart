import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/*
  Servicio de Comunicación API:
  Gestiona todas las peticiones HTTP salientes hacia el servidor Backend.
  Encapsula la lógica de cabeceras, autenticación JWT y manejo de respuestas.
*/
class ApiService {
  // Determina la URL base según el entorno de ejecución (Web o Emulador Android).
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:3000/api";
    return "http://10.0.2.2:3000/api"; 
  }

  // Genera las cabeceras estándar incluyendo el token de autorización si existe.
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Realiza una petición GET al servidor.
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl$endpoint"), headers: await _getHeaders());
    return _handleResponse(response);
  }

  // Realiza una petición POST enviando datos en formato JSON.
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl$endpoint"), headers: await _getHeaders(), body: jsonEncode(data));
    return _handleResponse(response);
  }

  // Realiza una petición PUT para actualizar recursos existentes.
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl$endpoint"), headers: await _getHeaders(), body: jsonEncode(data));
    return _handleResponse(response);
  }

  // Realiza una petición DELETE para eliminar recursos del servidor.
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse("$baseUrl$endpoint"), headers: await _getHeaders());
    return _handleResponse(response);
  }

  // Centraliza el manejo de respuestas HTTP y errores de servidor.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error del servidor: ${response.statusCode} - ${response.body}");
    }
  }
}
