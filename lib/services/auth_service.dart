import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/*
  Servicio de Autenticación:
  Gestiona los procesos de registro, inicio y cierre de sesión de usuarios.
  Utiliza JWT (JSON Web Tokens) para mantener la persistencia de la sesión.
*/
class AuthService {
  // Construye la URL base para el módulo de autenticación.
  final String baseUrl = ApiService.baseUrl + "/auth";

  /// Registra un nuevo usuario en la base de datos centralizada.
  Future<bool> register(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );
      // Retorna éxito si el código de respuesta es 200 (OK).
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Valida las credenciales del usuario y almacena el token JWT si el acceso es exitoso.
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        // Persistencia del token y el rol del usuario para control de navegación.
        await prefs.setString('jwt_token', data['token']);
        await prefs.setString('user_role', data['role']); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Elimina los datos de sesión local para finalizar la autenticación.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
  }

  /// Verifica si existe un token almacenado para determinar si el usuario ha iniciado sesión.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }

  /// Recupera el nivel de privilegios (admin o customer) del usuario actual.
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }
}
