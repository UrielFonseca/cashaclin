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

  void navigateTo(String route) {
    if (Navigator.canPop(context)) {
      final ScaffoldState? scaffold = Scaffold.maybeOf(context);
      if (scaffold?.isDrawerOpen ?? false) {
        Navigator.pop(context);
      }
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final currentRoute = ModalRoute.of(context)?.settings.name ?? "/admin";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      drawer: isDesktop ? null : _buildDrawer(currentRoute),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Casha Clin - Admin",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, "/"),
              icon: const Icon(Icons.logout, size: 18, color: Colors.white),
              label: const Text("Salir", style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(currentRoute),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(String currentRoute) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isActive = currentRoute == item.route;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isActive ? const Color(0xFF2563EB) : Colors.grey,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? const Color(0xFF2563EB) : Colors.black87,
                    ),
                  ),
                  tileColor: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () => navigateTo(item.route),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("v1.0.2", style: TextStyle(color: Colors.grey, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildDrawer(String currentRoute) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Center(
              child: Text(
                "MENU",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...navItems.map((item) {
            final isActive = currentRoute == item.route;
            return ListTile(
              leading: Icon(item.icon, color: isActive ? Colors.blue : null),
              title: Text(item.label, style: TextStyle(color: isActive ? Colors.blue : null)),
              selected: isActive,
              onTap: () => navigateTo(item.route),
            );
          }),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  _NavItem(this.label, this.icon, this.route);
}
