import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final auth = AuthService();
    bool success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: Credenciales inválidas"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3673),
      body: Stack(
        children: [
          if (_controller != null)
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Círculo arriba izquierda
                    _buildCircle(
                      top: 100,
                      left: 20,
                      size: 150,
                      color: const Color(
                        0xFF42A5F5,
                      ).withOpacity(0.3), // Azul claro brillante
                      speed: 1.0,
                    ),
                    // Círculo abajo derecha
                    _buildCircle(
                      bottom: 80,
                      right: 10,
                      size: 220,
                      color: const Color(0xFF2196F3).withOpacity(0.2),
                      speed: 1.2,
                    ),
                    // Círculo central moviéndose sutilmente
                    _buildCircle(
                      top: 300,
                      right: 50,
                      size: 100,
                      color: const Color.fromARGB(
                        255,
                        229,
                        251,
                        187,
                      ).withOpacity(0.2),
                      speed: 0.7,
                    ),
                  ],
                );
              },
            ),

          // --- TARJETA DE LOGIN ---
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 600,
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  color: Colors.white.withOpacity(
                    0.95,
                  ), //toque de transparencia estética
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 50,
                      horizontal: 35,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFF1E3A8A),
                            ),
                            children: [
                              TextSpan(
                                text: "Casha ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                ), // Más delgado
                              ),
                              TextSpan(
                                text: "Clin Pro",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ), // Súper negrita
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Correo electrónico",
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Color.fromARGB(255, 255, 252, 103),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color.fromARGB(255, 255, 252, 103),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "INICIAR SESIÓN",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            "¿No tienes cuenta? Regístrate aquí",
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w600,
                            ),
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

  // Widget de círculo
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
    // Movimiento en X e Y
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
