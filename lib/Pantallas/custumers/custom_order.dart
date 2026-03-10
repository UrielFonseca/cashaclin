import 'package:flutter/material.dart';

class CustomOrderPage extends StatelessWidget {
  const CustomOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pedido Especial",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
          ),
          const Text(
            "Solicita productos por volumen o personalizados",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _formField("Nombre Completo", Icons.person_outline),
                _formField("Correo Electrónico", Icons.email_outlined),
                _formField("Fecha Estimada", Icons.calendar_today_outlined),
                _formField("Detalles del pedido", Icons.chat_bubble_outline, maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Solicitud enviada")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Enviar Solicitud", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Text("¿Necesitas ayuda?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          isMobile 
            ? Column(
                children: [
                  _contactCard(Icons.phone, "Llámanos", "800-CASHA-CLIN"),
                  const SizedBox(height: 12),
                  _contactCard(Icons.message, "WhatsApp", "55 1234 5678"),
                  const SizedBox(height: 12),
                  _contactCard(Icons.alternate_email, "Email", "ventas@cashaclin.com"),
                ],
              )
            : Row(
                children: [
                  _contactCard(Icons.phone, "Llámanos", "800-CASHA-CLIN"),
                  const SizedBox(width: 12),
                  _contactCard(Icons.message, "WhatsApp", "55 1234 5678"),
                  const SizedBox(width: 12),
                  _contactCard(Icons.alternate_email, "Email", "ventas@cashaclin.com"),
                ],
              ),
        ],
      ),
    );
  }

  Widget _formField(String label, IconData icon, {int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    ),
  );

  Widget _contactCard(IconData icon, String title, String val) => Container(
    padding: const EdgeInsets.all(12),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFEFF6FF),
          radius: 20,
          child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(val, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
}
