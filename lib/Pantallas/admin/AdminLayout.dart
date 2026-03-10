import 'package:flutter/material.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final List<_NavItem> navItems = [
    _NavItem("Dashboard", Icons.dashboard, "/admin"),
    _NavItem("Productos", Icons.inventory_2, "/admin/products"),
    _NavItem("Inventario", Icons.warehouse, "/admin/inventory"),
    _NavItem("Clientes", Icons.people, "/admin/customers"),
    _NavItem("Ventas", Icons.shopping_bag, "/admin/sales"),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? "/admin";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Casha Clin - Admin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/"),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: isMobile ? _buildDrawer(currentRoute) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(currentRoute),
          Expanded(child: widget.child), // Eliminamos el ScrollView de aquí
        ],
      ),
    );
  }

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

  Widget _buildDrawer(String currentRoute) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Center(child: Text("MENU ADMIN", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          ...navItems.map((item) => _menuItem(item, currentRoute, isDrawer: true)),
        ],
      ),
    );
  }

  Widget _menuItem(_NavItem item, String currentRoute, {bool isDrawer = false}) {
    final bool isActive = currentRoute == item.route;
    return ListTile(
      leading: Icon(item.icon, color: isActive ? const Color(0xFF2563EB) : Colors.grey),
      title: Text(item.label, style: TextStyle(color: isActive ? const Color(0xFF2563EB) : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        if (isDrawer) Navigator.pop(context);
        Navigator.pushReplacementNamed(context, item.route);
      },
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  _NavItem(this.label, this.icon, this.route);
}
