import 'package:flutter/material.dart';
import '../../repositories/sale_repository.dart';

/*
  Pantalla de Seguimiento de Pedidos:
  Permite al cliente visualizar el estado de sus transacciones y solicitudes especiales.
  Implementa un flujo de negociación en tiempo real mediante un sistema de mensajería interna.
*/
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final SaleRepository _repository = SaleRepository();
  List<Map<String, dynamic>> _myOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializa la carga de pedidos vinculados a la cuenta actual.
    _load();
  }

  /// Recupera los pedidos asociados al usuario autenticado mediante su token JWT.
  void _load() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _repository.getMySales();
      setState(() => _myOrders = orders);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error operativo: No se pudo sincronizar el historial de pedidos.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /*
    Diálogo de Negociación y Detalle:
    Muestra el desglose del pedido y permite al usuario aceptar cotizaciones 
    o enviar mensajes de respuesta a la administración.
  */
  void _showNegotiation(Map<String, dynamic> order) {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(order['type'] == 'especial' ? "Negociación de Pedido Especial" : "Detalle de Transacción"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Estatus Actual: ${order['status']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Monto Cotizado: \$${order['total']}",
                  style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
              const Divider(),
              const Text("Bitácora de Comunicación:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              // Despliegue del hilo de mensajes entre el cliente y el administrador.
              ...(order['messages'] as List? ?? []).map((m) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(m['sender'] == 'admin' ? "Administración" : "Usuario",
                        style: TextStyle(
                            color: m['sender'] == 'admin'
                                ? Colors.blue
                                : Colors.black87,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(m['text']),
                  )),
              // Habilita la entrada de texto si la negociación está activa.
              if (order['status'] == 'Cotizado' || order['status'] == 'Esperando aprobación') ...[
                const Divider(),
                TextField(
                    controller: msgCtrl,
                    decoration:
                        const InputDecoration(labelText: "Escribir respuesta...", border: OutlineInputBorder())),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar")),
          if (order['status'] == 'Cotizado') ...[
            // Acción para aceptar la propuesta económica del administrador.
            ElevatedButton(
              onPressed: () async {
                await _repository.negotiateSale(order['_id'] ?? order['id'],
                    status: "Aceptado por cliente",
                    message: "El cliente ha aceptado la cotización propuesta.");
                Navigator.pop(context);
                _load();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Aceptar Cotización",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
          if (order['status'] == 'Cotizado' || order['status'] == 'Esperando aprobación') ...[
            // Envía un mensaje adicional al administrador.
            ElevatedButton(
              onPressed: () async {
                if (msgCtrl.text.isEmpty) return;
                await _repository.negotiateSale(order['_id'] ?? order['id'],
                    message: msgCtrl.text);
                Navigator.pop(context);
                _load();
              },
              child: const Text("Enviar Mensaje"),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mis Pedidos",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Seguimiento de solicitudes y transacciones",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.sync, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          // Gestión de estados de carga y visualización de lista.
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
                child: _myOrders.isEmpty
                    ? const Center(child: Text("No se registran pedidos en esta cuenta."))
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                            itemCount: _myOrders.length,
                            itemBuilder: (context, index) {
                              final o = _myOrders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: Icon(
                                      o['type'] == 'especial'
                                          ? Icons.assignment_turned_in_outlined
                                          : Icons.shopping_cart_outlined,
                                      color: o['type'] == 'especial'
                                          ? Colors.indigo
                                          : Colors.blue),
                                  title: Text(
                                      "Orden: ${o['date']?.toString().split('T')[0] ?? 'N/A'}"),
                                  subtitle: Text("Estado: ${o['status']}"),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () => _showNegotiation(o),
                                ),
                              );
                            }),
                      ))
        ],
      ),
    );
  }
}
