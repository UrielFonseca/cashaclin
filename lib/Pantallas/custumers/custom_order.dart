import 'package:flutter/material.dart';

class CustomOrderPage extends StatelessWidget {
  const CustomOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pedido Especial",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
          ),
          const Text(
            "Solicita productos por volumen o artículos personalizados",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _formField("Nombre Completo", Icons.person_outline),
                _formField("Correo Electrónico", Icons.email_outlined),
                _formField("Fecha Estimada de Entrega", Icons.calendar_today_outlined),
                _formField(
                  "Detalles de tu pedido (cantidades, productos específicos)",
                  Icons.chat_bubble_outline,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Solicitud enviada correctamente")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Enviar Solicitud",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "¿Necesitas ayuda inmediata?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _contactCard(Icons.phone, "Llámanos", "800-CASHA-CLIN"),
              const SizedBox(width: 12),
              _contactCard(Icons.message, "WhatsApp", "55 1234 5678"),
              const SizedBox(width: 12),
              _contactCard(Icons.alternate_email, "Email", "ventas@cashaclin.com"),
            ],
          )
        ],
      ),
    );
  }

  Widget _formField(String label, IconData icon, {int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    ),
  );

  Widget _contactCard(IconData icon, String title, String val) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            val,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
