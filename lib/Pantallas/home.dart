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
              Color(0xFF2563EB), // blue-600
              Color(0xFF1D4ED8), // blue-700
              Color(0xFF1E3A8A), // blue-900
            ],
          ),
        ),
        child: Stack(
          children: [
            // 🔵 Background glow circles
            Positioned(
              top: -150,
              left: -100,
              child: _buildGlowCircle(300, Colors.blueAccent.withOpacity(0.2)),
            ),
            Positioned(
              top: 200,
              right: -100,
              child: _buildGlowCircle(300, Colors.blue.withOpacity(0.2)),
            ),
            Positioned(
              bottom: -150,
              left: 120,
              child: _buildGlowCircle(300, Colors.lightBlue.withOpacity(0.2)),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ✨ Icono principal
                    const Icon(Icons.auto_awesome,
                        size: 70, color: Colors.yellowAccent),

                    const SizedBox(height: 20),

                    const Text(
                      "Casha Clin",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Productos de Limpieza Especializados",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.yellowAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Tu proveedor de confianza en artículos de limpieza para el hogar y empresas",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 50),

                    // 🟦 Cards principales
                    _mainCard(
                      context,
                      icon: Icons.dashboard,
                      title: "Panel de Administración",
                      description:
                      "Gestiona productos, inventario, clientes y ventas",
                      color1: const Color(0xFF3B82F6),
                      color2: const Color(0xFF2563EB),
                      onTap: () {
                        Navigator.pushNamed(context, "/admin");
                      },
                    ),

                    const SizedBox(height: 20),

                    _mainCard(
                      context,
                      icon: Icons.shopping_cart,
                      title: "Tienda en Línea",
                      description:
                      "Compra al menudeo o mayoreo con precios especiales",
                      color1: const Color(0xFFFACC15),
                      color2: const Color(0xFFEAB308),
                      onTap: () {
                        Navigator.pushNamed(context, "/shop");
                      },
                    ),

                    const SizedBox(height: 50),

                    // 🟩 Features
                    _featureCard(
                      icon: Icons.store,
                      title: "Productos Especializados",
                      description:
                      "Amplio catálogo de productos de limpieza profesionales",
                    ),
                    const SizedBox(height: 16),
                    _featureCard(
                      icon: Icons.shopping_cart_checkout,
                      title: "Compra Fácil",
                      description:
                      "Proceso de compra sencillo para minoristas y mayoristas",
                    ),
                    const SizedBox(height: 16),
                    _featureCard(
                      icon: Icons.attach_money,
                      title: "Precios Accesibles",
                      description:
                      "Mejores precios para amas de casa y empresas",
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color1, color2],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style:
              const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}