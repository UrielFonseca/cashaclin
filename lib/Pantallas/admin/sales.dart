import 'package:flutter/material.dart';
import '../../repositories/sale_repository.dart';

/*
  Pantalla de Ventas y Pedidos Especiales:
  Interfaz administrativa para la gestión de transacciones comerciales.
  Permite diferenciar entre ventas directas de carrito y solicitudes de cotización.
*/
class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final SaleRepository _repository = SaleRepository();
  late Future<List<Map<String, dynamic>>> _salesFuture;
  bool _showSpecialOnly = false; // Estado para el filtrado de pedidos especiales.

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Recupera el listado completo de ventas desde el servidor central.
  void _refresh() {
    setState(() {
      _salesFuture = _repository.getSales();
    });
  }

  /*
    Diálogo de Negociación:
    Herramienta interactiva para que el administrador asigne precios a solicitudes 
    especiales y mantenga una comunicación directa con el cliente.
  */
  void _negotiateDialog(Map<String, dynamic> sale) {
    final priceCtrl = TextEditingController(text: sale['total']?.toString() ?? '0');
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gestión de Cotización Especial"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Solicitante: ${sale['customerName']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Contacto: ${sale['customerEmail']}"),
              const Divider(),
              const Text("Bitácora de Comunicación:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              if (sale['messages'] != null)
                ... (sale['messages'] as List).map((m) => ListTile(
                  dense: true,
                  title: Text(m['sender'] == 'admin' ? "Administrador" : "Cliente"),
                  subtitle: Text(m['text']),
                )),
              const Divider(),
              // Entrada de datos para la oferta económica.
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Monto Total Cotizado", prefixText: "\$ "),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              // Espacio para retroalimentación técnica o comercial.
              TextField(
                controller: msgCtrl,
                decoration: const InputDecoration(labelText: "Mensaje Informativo", hintText: "Ej: Descuento aplicado por volumen..."),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          // Envía la propuesta de precio y cambia el estatus a 'Cotizado'.
          ElevatedButton(
            onPressed: () async {
              await _repository.negotiateSale(
                sale['_id'] ?? sale['id'],
                total: double.tryParse(priceCtrl.text),
                status: "Cotizado",
                message: msgCtrl.text,
              );
              Navigator.pop(context);
              _refresh();
            },
            child: const Text("Enviar Propuesta"),
          ),
          // Finaliza la solicitud sin aprobación.
          ElevatedButton(
            onPressed: () async {
              await _repository.negotiateSale(
                sale['_id'] ?? sale['id'],
                status: "Rechazado",
                message: msgCtrl.text,
              );
              Navigator.pop(context);
              _refresh();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Rechazar Solicitud", style: TextStyle(color: Colors.white)),
          ),
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
              const Text("Control de Ventas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              // Filtro avanzado para segmentación de pedidos.
              FilterChip(
                label: const Text("Pedidos Especiales"),
                selected: _showSpecialOnly,
                onSelected: (val) => setState(() => _showSpecialOnly = val),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Representación tabular con scroll bidireccional.
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _salesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                var sales = snapshot.data ?? [];
                if (_showSpecialOnly) sales = sales.where((s) => s['type'] == 'especial').toList();

                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 25,
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text("Fecha")),
                          DataColumn(label: Text("Cliente")),
                          DataColumn(label: Text("Monto")),
                          DataColumn(label: Text("Estado Operativo")),
                        ],
                        rows: sales.map((s) => DataRow(
                          onSelectChanged: (selected) {
                            if (s['type'] == 'especial') _negotiateDialog(s);
                          },
                          cells: [
                            DataCell(Text(s['date']?.toString().split('T')[0] ?? 'N/A')),
                            DataCell(Text(s['customerName'] ?? 'Anónimo')),
                            DataCell(Text("\$${s['total']?.toStringAsFixed(2)}")),
                            DataCell(_buildStatusIndicator(s['status'])),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Genera un indicador de estado con código de colores según el progreso del pedido.
  Widget _buildStatusIndicator(String? status) {
    Color col = Colors.blueGrey;
    if (status == "Aceptado por cliente" || status == "Completada") col = Colors.green;
    if (status == "Rechazado") col = Colors.red;
    if (status == "Cotizado") col = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: col.withAlpha(25), borderRadius: BorderRadius.circular(8)),
      child: Text(status ?? 'Pendiente', style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
