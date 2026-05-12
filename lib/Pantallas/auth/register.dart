import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer'; 
  bool _isLoading = false;

  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    final success = await AuthService().register(
      _emailController.text, 
      _passwordController.text, 
      _selectedRole
    );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro exitoso, inicia sesión"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al registrar"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3673),
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // --- CÍRCULOS ANIMADOS 
          if (_controller != null)
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildCircle(top: 150, left: -20, size: 180, color: const Color(0xFF42A5F5).withOpacity(0.2), speed: 1.0),
                    _buildCircle(bottom: 50, right: 20, size: 200, color: const Color(0xFF2196F3).withOpacity(0.15), speed: 1.3),
                  ],
                );
              },
            ),

          // --- TARJETA DE REGISTRO ---
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 600,
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Nueva Cuenta",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1E3A8A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 35),
                        
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email_outlined, color: Color.fromARGB(255, 255, 252, 103)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock_outline, color: Color.fromARGB(255, 255, 252, 103)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dropdown Estilizado
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          onChanged: (v) => setState(() => _selectedRole = v!),
                          decoration: const InputDecoration(
                            labelText: "Tipo de Usuario",
                            prefixIcon: Icon(Icons.badge_outlined, color: Color.fromARGB(255, 255, 252, 103)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'customer', child: Text("Cliente")),
                            DropdownMenuItem(value: 'admin', child: Text("Administrador")),
                          ],
                        ),
                        
                        const SizedBox(height: 45),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : const Text("REGISTRARSE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  // Helper de círculos 
  Widget _buildCircle({double? top, double? left, double? right, double? bottom, required double size, required Color color, required double speed}) {
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 30, spreadRadius: 10)
          ],
        ),
      ),
    );
  }
}
