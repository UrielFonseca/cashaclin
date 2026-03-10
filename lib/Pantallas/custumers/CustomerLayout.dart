import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import 'catalog.dart';
import 'cart.dart';
import 'custom_order.dart';

class CustomerLayout extends StatefulWidget {
  const CustomerLayout({super.key});

  @override
  State<CustomerLayout> createState() => _CustomerLayoutState();
}

class _CustomerLayoutState extends State<CustomerLayout> {
  int _selectedIndex = 0;
  List<CartItem> cart = [];

  void addToCart(Product product, int quantity) {
    setState(() {
      final index = cart.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        cart[index].quantity += quantity;
      } else {
        cart.add(CartItem(product: product, quantity: quantity));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} añadido al carrito"), duration: const Duration(milliseconds: 500)),
    );
  }

  void updateCartQuantity(int index, int delta) {
    setState(() {
      cart[index].quantity += delta;
      if (cart[index].quantity <= 0) cart.removeAt(index);
    });
  }

  void emptyCart() => setState(() => cart.clear());

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    
    final List<Widget> pages = [
      CatalogPage(onAddToCart: addToCart),
      CartPage(
        cart: cart,
        onUpdateQuantity: updateCartQuantity,
        onEmptyCart: emptyCart,
        onGoToCatalog: () => setState(() => _selectedIndex = 0),
      ),
      const CustomOrderPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: isMobile ? AppBar(
        title: const Text("Casha Clin", style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ) : null,
      drawer: isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF1E3A8A),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.auto_awesome, size: 48, color: Colors.yellowAccent),
          const SizedBox(height: 40),
          _menuItem(0, "Catálogo", Icons.grid_view_rounded),
          _menuItem(1, "Carrito (${cart.length})", Icons.shopping_cart_rounded),
          _menuItem(2, "Pedido Especial", Icons.edit_note_rounded),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text("Salir", style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Center(child: Text("MENU", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
          ),
          _menuItem(0, "Catálogo", Icons.grid_view_rounded, isDrawer: true),
          _menuItem(1, "Carrito (${cart.length})", Icons.shopping_cart_rounded, isDrawer: true),
          _menuItem(2, "Pedido Especial", Icons.edit_note_rounded, isDrawer: true),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Ir al Inicio"),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(int index, String label, IconData icon, {bool isDrawer = false}) {
    final isActive = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.yellowAccent : (isDrawer ? Colors.blue : Colors.white70)),
      title: Text(label, style: TextStyle(color: isActive ? Colors.white : (isDrawer ? Colors.black87 : Colors.white70), fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      selected: isActive,
      onTap: () {
        if (isDrawer) Navigator.pop(context);
        setState(() => _selectedIndex = index);
      },
    );
  }
}
