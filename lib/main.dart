import 'package:flutter/material.dart';
import 'Pantallas/home.dart';
import 'Pantallas/admin/AdminLayout.dart';
import 'Pantallas/admin/dashboard.dart';
import 'Pantallas/admin/inventory.dart';
import 'Pantallas/admin/Customers.dart';
import 'Pantallas/admin/sales.dart';
import 'Pantallas/admin/products.dart';
import 'Pantallas/custumers/CustomerLayout.dart';
import 'Pantallas/auth/login.dart';
import 'Pantallas/auth/register.dart';
import 'services/auth_service.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de usar servicios asíncronos.
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  // Verifica si el usuario tiene una sesión activa mediante el token JWT.
  final bool loggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Casha Clin Pro',
      theme: ThemeData(
        useMaterial3: true,
        // Definición de color primario corporativo.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
      ),
      // Ruta inicial dinámica: si no hay sesión, redirige al login.
      initialRoute: isLoggedIn ? '/' : '/login', 
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/': (context) => const HomePage(),
        // Rutas administrativas protegidas por el Layout del administrador.
        '/admin': (context) => const AdminLayout(child: const Dashboard()),
        '/admin/products': (context) => const AdminLayout(child: const ProductsPage()),
        '/admin/inventory': (context) => const AdminLayout(child: const Inventory()),
        '/admin/customers': (context) => const AdminLayout(child: const Customers()),
        '/admin/sales': (context) => const AdminLayout(child: const Sales()),
        // Ruta del portal del cliente.
        '/shop': (context) => const CustomerLayout(),
      },
    );
  }
}
