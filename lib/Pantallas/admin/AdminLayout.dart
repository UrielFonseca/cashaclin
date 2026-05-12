import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

/*
  Layout principal del Administrador:
  Este componente define la estructura visual común para todas las pantallas de administración.
  Implementa un diseño responsivo que alterna entre una barra lateral fija (Escritorio) 
  y un menú lateral desplegable (Móvil).
*/
class AdminLayout extends StatefulWidget {
  final Widget child; // Contenido dinámico de la página actual.

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  // Definición de los ítems de navegación para el administrador.
  final List<_NavItem> navItems = [
    _NavItem("Dashboard", Icons.dashboard, "/admin"),
    _NavItem("Productos", Icons.inventory_2, "/admin/products"),
    _NavItem("Inventario", Icons.warehouse, "/admin/inventory"),
    _NavItem("Clientes", Icons.people, "/admin/customers"),
    _NavItem("Ventas", Icons.shopping_bag, "/admin/sales"),
  ];

  final AuthService _authService = AuthService();

  /*
    Lógica de cierre de sesión:
    Limpia las credenciales JWT del almacenamiento local y redirige al login.
  */
  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos si el dispositivo es móvil basado en el ancho de pantalla.
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? "/admin";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Casha Clin - Administración", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/"),
            icon: const Icon(Icons.home),
            tooltip: "Volver al Portal de Inicio",
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: "Finalizar Sesión",
          ),
        ],
      ),
      // Muestra el Drawer solo en dispositivos móviles.
      drawer: isMobile ? _buildDrawer(currentRoute) : null,
      body: Row(
        children: [
          // Muestra la barra lateral fija solo en pantallas grandes.
          if (!isMobile) _buildSidebar(currentRoute),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// Construye la barra lateral para la versión de escritorio.
  Widget _buildSidebar(String currentRoute) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          ...navItems.map((item) => _menuItem(item, currentRoute)),
        ],
      ),
    );
  }

  /// Construye el menú desplegable para la versión móvil.
  Widget _buildDrawer(String currentRoute) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Center(
              child: Text(
                "MENÚ ADMIN", 
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
              )
            ),
          ),
          ...navItems.map((item) => _menuItem(item, currentRoute, isDrawer: true)),
        ],
      ),
    );
  }

  /// Crea un elemento de menú reutilizable con detección de ruta activa.
  Widget _menuItem(_NavItem item, String currentRoute, {bool isDrawer = false}) {
    final bool isActive = currentRoute == item.route;
    return ListTile(
      leading: Icon(item.icon, color: isActive ? const Color(0xFF2563EB) : Colors.grey),
      title: Text(
        item.label, 
        style: TextStyle(
          color: isActive ? const Color(0xFF2563EB) : Colors.black87, 
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal
        )
      ),
      selected: isActive,
      onTap: () {
        if (isDrawer) Navigator.pop(context);
        Navigator.pushReplacementNamed(context, item.route);
      },
    );
  }
}

/// Modelo de datos interno para los elementos de navegación.
class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  _NavItem(this.label, this.icon, this.route);
}
