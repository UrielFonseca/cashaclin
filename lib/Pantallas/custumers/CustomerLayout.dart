import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import 'catalog.dart';
import 'cart.dart';
import 'custom_order.dart';
import 'my_orders.dart';

/*
  Layout Principal del Cliente:
  Este componente gestiona la navegación del usuario final y el estado global del carrito de compras.
  Utiliza un diseño responsivo que alterna entre Sidebar (Escritorio) y Drawer (Móvil).
*/
class CustomerLayout extends StatefulWidget {
  const CustomerLayout({super.key});

  @override
  State<CustomerLayout> createState() => _CustomerLayoutState();
}

class _CustomerLayoutState extends State<CustomerLayout> {
  int _selectedIndex = 0; // Índice de la página activa.
  List<CartItem> cart = []; // Lista de productos seleccionados por el usuario.

  /*
    Lógica para añadir productos al carrito:
    Si el producto ya existe, incrementa la cantidad. 
    De lo contrario, añade un nuevo ítem a la lista.
  */
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
        content: Text("Producto '${product.name}' añadido al carrito"), 
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    
    // Definición de las páginas disponibles en el portal del cliente.
    final List<Widget> pages = [
      CatalogPage(onAddToCart: addToCart),
      CartPage(
        cart: cart,
        onUpdateQuantity: (i, d) => setState(() {
          cart[i].quantity += d;
          if (cart[i].quantity <= 0) cart.removeAt(i);
        }),
        onEmptyCart: () => setState(() => cart.clear()),
        onGoToCatalog: () => setState(() => _selectedIndex = 0),
      ),
      const CustomOrderPage(),
      const MyOrdersPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: isMobile ? AppBar(
        title: const Text("Casha Clin Pro", style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
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

  /// Construye la barra lateral de navegación para la versión web/escritorio.
  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF1E3A8A),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.store, size: 48, color: Color.fromARGB(255, 243, 224, 113)),
          const Text("Portal Cliente", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _menuItem(0, "Catálogo de Productos", Icons.grid_view_rounded),
          _menuItem(1, "Carrito de Compras", Icons.shopping_cart_rounded),
          _menuItem(2, "Pedido Especial", Icons.edit_note_rounded),
          _menuItem(3, "Seguimiento de Pedidos", Icons.assignment_turned_in_rounded),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text("Finalizar Sesión", style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Construye el menú desplegable para la versión móvil.
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Center(child: Text("MENU", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
          ),
          _menuItem(0, "Catálogo", Icons.grid_view_rounded, isDrawer: true),
          _menuItem(1, "Carrito", Icons.shopping_cart_rounded, isDrawer: true),
          _menuItem(2, "Pedido Especial", Icons.edit_note_rounded, isDrawer: true),
          _menuItem(3, "Mis Pedidos", Icons.assignment_turned_in_rounded, isDrawer: true),
        ],
      ),
    );
  }

  /// Genera un ítem de menú interactivo.
  Widget _menuItem(int index, String label, IconData icon, {bool isDrawer = false}) {
    final isActive = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? const Color(0xFFFFD700) : (isDrawer ? Colors.blueGrey : Colors.white70)),
      title: Text(label, style: TextStyle(color: isActive ? Colors.white : (isDrawer ? Colors.black87 : Colors.white70), fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      selected: isActive,
      onTap: () {
        if (isDrawer) Navigator.pop(context);
        setState(() => _selectedIndex = index);
      },
    );
  }
}
