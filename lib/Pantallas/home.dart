import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Pantalla principal que sirve como centro de navegación para administradores y clientes.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    // Verifica el rol del usuario al cargar la pantalla.
    _checkRole();
  }

  /// Recupera el rol del usuario desde el almacenamiento local.
  void _checkRole() async {
    final role = await _authService.getRole();
    setState(() {
      _userRole = role;
    });
  }

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
            // Círculos decorativos de fondo.
            Positioned(
              top: -150,
              left: -100,
              child: _buildGlowCircle(300, const Color(0x4D448AFF)),
            ),
            Positioned(
              bottom: -150,
              left: 120,
              child: _buildGlowCircle(300, const Color(0x4D03A9F4)),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Logotipo de la empresa.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(110),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(10),
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
                      "Casha Clin Pro",
                      style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Productos de Limpieza Especializados",
                      style: TextStyle(fontSize: 18, color: Colors.yellowAccent, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Sección visible únicamente para usuarios con privilegios administrativos.
                    if (_userRole == 'admin') ...[
                      _mainCard(
                        context,
                        icon: Icons.admin_panel_settings,
                        title: "Panel de Administración",
                        description: "Gestión de stock, ventas y clientes",
                        color1: const Color(0xFF3B82F6),
                        color2: const Color(0xFF2563EB),
                        onTap: () => Navigator.pushNamed(context, "/admin"),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Acceso al portal de compras para el cliente.
                    _mainCard(
                      context,
                      icon: Icons.shopping_bag,
                      title: "Tienda en Línea",
                      description: "Explora nuestro catálogo y realiza pedidos",
                      color1: const Color(0xFFFACC15),
                      color2: const Color(0xFFEAB308),
                      onTap: () => Navigator.pushNamed(context, "/shop"),
                    ),

                    const SizedBox(height: 40),

                    // Tarjetas informativas sobre beneficios del servicio.
                    _featureCard(
                      icon: Icons.security,
                      title: "Garantía de Calidad",
                      description: "Productos certificados para uso industrial y hogar",
                    ),
                    const SizedBox(height: 16),
                    _featureCard(
                      icon: Icons.local_shipping,
                      title: "Entregas Rápidas",
                      description: "Surtimos tu pedido en tiempo récord",
                    ),
                    
                    const SizedBox(height: 20),
                    // Opción para cerrar la sesión actual y limpiar el token JWT.
                    TextButton.icon(
                      onPressed: () async {
                        await _authService.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white70)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un círculo decorativo con desenfoque simulado.
  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// Construye una tarjeta interactiva para las acciones principales.
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
          boxShadow: [BoxShadow(color: const Color(0x42000000), blurRadius: 10, offset: const Offset(0, 4))],
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

  /// Construye un componente informativo horizontal.
  Widget _featureCard({required IconData icon, required String title, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFE3F2FD), child: Icon(icon, color: Colors.blue)),
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
