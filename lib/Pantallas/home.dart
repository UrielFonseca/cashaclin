import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  String? _userRole;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _checkRole();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _checkRole() async {
    final role = await _authService.getRole();
    setState(() {
      _userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3673),
      body: Stack(
        children: [
          // --- FONDO ANIMADO ---
          if (_controller != null)
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildCircle(
                      top: -50,
                      left: -30,
                      size: 250,
                      color: const Color(0xFF42A5F5).withOpacity(0.15),
                      speed: 1.0,
                    ),
                    _buildCircle(
                      bottom: 100,
                      right: -40,
                      size: 200,
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      speed: 1.5,
                    ),
                  ],
                );
              },
            ),

          // --- CONTENIDO ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Logotipo con sombra suave
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                'assets/images/casha_clin_logo.jpg',
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.auto_awesome,
                                      size: 60,
                                      color: Color(0xFF1E3A8A),
                                    ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Título
                        const Text(
                          "Casha Clin Pro",
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const Text(
                          "Limpieza Especializada",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Panel Admin
                        if (_userRole == 'admin') ...[
                          _mainCard(
                            context,
                            icon: Icons.admin_panel_settings_rounded,
                            title: "Panel Administrativo",
                            description: "Gestión de stock y clientes",
                            accentColor: const Color(0xFF1E3A8A),
                            onTap: () => Navigator.pushNamed(context, "/admin"),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Tienda
                        _mainCard(
                          context,
                          icon: Icons.shopping_cart_rounded,
                          title: "Tienda en Línea",
                          description: "Explora nuestro catálogo completo",
                          accentColor: const Color(0xFFD4AF37),
                          onTap: () => Navigator.pushNamed(context, "/shop"),
                        ),

                        const SizedBox(height: 30),

                        // Features
                        _featureCard(
                          Icons.verified_user_rounded,
                          "Calidad Garantizada",
                        ),

                        const SizedBox(height: 12),

                        _featureCard(
                          Icons.local_shipping_rounded,
                          "Envíos Express",
                        ),

                        const SizedBox(height: 30),

                        TextButton.icon(
                          onPressed: () async {
                            await _authService.logout();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            "Cerrar Sesión",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de Círculo Animado
  Widget _buildCircle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required double speed,
  }) {
    final double animValue = _controller?.value ?? 0.0;
    final double offsetX = math.sin(animValue * 2 * math.pi * speed) * 20;
    final double offsetY = math.cos(animValue * 2 * math.pi * speed) * 20;

    return Positioned(
      top: top != null ? top + offsetY : null,
      left: left != null ? left + offsetX : null,
      right: right != null ? right + offsetX : null,
      bottom: bottom != null ? bottom + offsetY : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  // Tarjeta principal
  Widget _mainCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Feature card
  Widget _featureCard(IconData icon, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
