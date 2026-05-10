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
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
      ),
      initialRoute: isLoggedIn ? '/' : '/login', 
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/': (context) => const HomePage(),
        '/admin': (context) => const AdminLayout(child: const Dashboard()),
        '/admin/products': (context) => const AdminLayout(child: const ProductsPage()),
        '/admin/inventory': (context) => const AdminLayout(child: const Inventory()),
        '/admin/customers': (context) => const AdminLayout(child: const Customers()),
        '/admin/sales': (context) => const AdminLayout(child: const Sales()),
        '/shop': (context) => const CustomerLayout(),
      },
    );
  }
}
