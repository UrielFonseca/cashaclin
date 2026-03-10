import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
              Color(0xFF1E3A8A),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              left: -100,
              child: _buildGlowCircle(300, const Color(0x4D448AFF)), // BlueAccent con opacity 0.3 en Hex
            ),
            Positioned(
              bottom: -150,
              left: 120,
              child: _buildGlowCircle(300, const Color(0x4D03A9F4)), // LightBlue con opacity 0.3 en Hex
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(110),
                      child: Container(
                        color: Colors.white,
                        child: Image.asset(
                          'assets/images/casha_clin_logo.jpg',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, size: 100, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Productos de Limpieza Especializados",
                      style: TextStyle(fontSize: 22, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Tu proveedor de confianza en artículos de limpieza para el hogar y empresas",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    _mainCard(
                      context,
                      icon: Icons.dashboard,
                      title: "Panel de Administración",
                      description: "Gestiona productos, inventario, clientes y ventas",
                      color1: const Color(0xFF3B82F6),
                      color2: const Color(0xFF2563EB),
                      onTap: () => Navigator.pushNamed(context, "/admin"),
                    ),
                    const SizedBox(height: 20),
                    _mainCard(
                      context,
                      icon: Icons.shopping_cart,
                      title: "Tienda en Línea",
                      description: "Compra al menudeo o mayoreo con precios especiales",
                      color1: const Color(0xFFFACC15),
                      color2: const Color(0xFFEAB308),
                      onTap: () => Navigator.pushNamed(context, "/shop"),
                    ),
                    const SizedBox(height: 40),

                    _featureCard(
                      icon: Icons.store,
                      title: "Productos Especializados",
                      description: "Amplio catálogo de productos profesionales",
                    ),
                    const SizedBox(height: 16),
                    _featureCard(
                      icon: Icons.attach_money,
                      title: "Precios Accesibles",
                      description: "Mejores precios para el hogar y empresas",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _mainCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color1, color2]),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({required IconData icon, required String title, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Blanco sólido
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.blue.shade100, child: Icon(icon, color: Colors.blue)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(description, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
