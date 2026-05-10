import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // 🔹 CONFIGURACIÓN DE URL PARA PROYECTO ESCOLAR
  // Para Web (Chrome): Usamos localhost
  // Para Emulador Android: Usamos 10.0.2.2
  // Para Celular Real: CAMBIA 'localhost' por la IP de tu PC (ej: 192.168.1.XX)
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/api";
    } else {
      // Dirección especial para que el emulador de Android vea tu computadora
      return "http://10.0.2.2:3000/api"; 
    }
  }

  // Obtener headers con JWT automáticamente
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // GET genérico
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Error de conexión: Revisa si tu servidor Node.js está encendido.");
    }
  }

  // POST genérico
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Error de conexión: Revisa si tu servidor Node.js está encendido.");
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Sesión expirada o no autorizado");
    } else {
      throw Exception("Error servidor (${response.statusCode}): ${response.body}");
    }
  }
}
