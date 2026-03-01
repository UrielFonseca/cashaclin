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
      SnackBar(
        content: Text("${product.name} añadido al carrito"),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
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
      body: Row(
        children: [
          // Sidebar apilado a la izquierda
          Container(
            width: 240,
            color: const Color(0xFF1E3A8A),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.auto_awesome, size: 48, color: Colors.yellowAccent),
                const SizedBox(height: 10),
                const Text(
                  "Casha Clin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _sidebarItem(0, "Catálogo", Icons.grid_view_rounded),
                _sidebarItem(1, "Carrito (${cart.length})", Icons.shopping_cart_rounded),
                _sidebarItem(2, "Pedido Especial", Icons.edit_note_rounded),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: const Text(
                    "Volver al Inicio",
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () => Navigator.pushReplacementNamed(context, "/"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, String label, IconData icon) {
    final isActive = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.yellowAccent : Colors.white70,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }
}
