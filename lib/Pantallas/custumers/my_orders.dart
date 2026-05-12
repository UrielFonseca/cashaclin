import 'package:flutter/material.dart';
import '../../repositories/sale_repository.dart';

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
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _repository.getMySales();
      setState(() => _myOrders = orders);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cargar tus pedidos")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNegotiation(Map<String, dynamic> order) {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(order['type'] == 'especial' ? "Negociación de Pedido" : "Detalle de Compra"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Estado: ${order['status']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Total Cotizado: \$${order['total']}",
                  style: const TextStyle(fontSize: 18, color: Colors.green)),
              const Divider(),
              const Text("Mensajes:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...(order['messages'] as List? ?? []).map((m) => ListTile(
                    dense: true,
                    title: Text(m['sender'] == 'admin' ? "Administrador" : "Tú",
                        style: TextStyle(
                            color: m['sender'] == 'admin'
                                ? Colors.blue
                                : Colors.black87)),
                    subtitle: Text(m['text']),
                  )),
              if (order['status'] == 'Cotizado') ...[
                const Divider(),
                TextField(
                    controller: msgCtrl,
                    decoration:
                        const InputDecoration(labelText: "Responder al admin...")),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar")),
          if (order['status'] == 'Cotizado') ...[
            ElevatedButton(
              onPressed: () async {
                await _repository.negotiateSale(order['_id'] ?? order['id'],
                    status: "Aceptado por cliente",
                    message: "He aceptado la cotización.");
                Navigator.pop(context);
                _load();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Aceptar Precio",
                  style: TextStyle(color: Colors.white)),
            ),
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
                  Text("Aquí verás el estado de tus compras y solicitudes",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
                child: _myOrders.isEmpty
                    ? const Center(child: Text("No tienes pedidos registrados"))
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
                                          ? Icons.stars
                                          : Icons.shopping_bag_outlined,
                                      color: o['type'] == 'especial'
                                          ? Colors.purple
                                          : Colors.blue),
                                  title: Text(
                                      "Pedido del ${o['date']?.toString().split('T')[0] ?? 'Hoy'}"),
                                  subtitle: Text("Estado: ${o['status']}"),
                                  trailing: const Icon(Icons.chevron_right),
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
