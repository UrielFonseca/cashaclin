import 'package:flutter/material.dart';
import 'Pantallas/home.dart';
import 'Pantallas/admin/AdminLayout.dart';
import 'Pantallas/admin/dashboard.dart';
import 'Pantallas/admin/inventory.dart';
import 'Pantallas/admin/Customers.dart';
import 'Pantallas/admin/sales.dart';
import 'Pantallas/admin/products.dart';
import 'Pantallas/custumers/CustomerLayout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Casha Clin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/admin': (context) => const AdminLayout(child: Dashboard()),
        '/admin/products': (context) => const AdminLayout(child: ProductsPage()),
        '/admin/inventory': (context) => const AdminLayout(child: Inventory()),
        '/admin/customers': (context) => const AdminLayout(child: Customers()),
        '/admin/sales': (context) => const AdminLayout(child: const Sales()),
        '/shop': (context) => const CustomerLayout(),
      },
    );
  }
}
