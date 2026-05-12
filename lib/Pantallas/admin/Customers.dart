import 'package:flutter/material.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/sale_repository.dart';

/*
  Pantalla de Gestión de Clientes:
  Módulo administrativo para la visualización y edición de perfiles de clientes.
  Incluye una funcionalidad integrada para consultar el historial de transacciones por usuario.
*/
class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final CustomerRepository _repository = CustomerRepository();
  final SaleRepository _saleRepository = SaleRepository();
  String searchTerm = '';
  late Future<List<Map<String, dynamic>>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Recupera el listado actualizado de clientes desde el repositorio.
  void _refresh() {
    setState(() {
      _customersFuture = _repository.getCustomers();
    });
  }

  /// Despliega un modal con la relación de compras realizadas por el cliente.
  void _showCustomerPurchases(String email, String name) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Historial de Compras - $name"),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _saleRepository.getSales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) 
                return const Center(child: CircularProgressIndicator());
              
              final sales = snapshot.data?.where((s) => s['customerEmail'] == email).toList() ?? [];
              
              if (sales.isEmpty) return const Text("No existen registros de ventas para este usuario.");

              return ListView.builder(
                shrinkWrap: true,
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ListTile(
                    title: Text("Fecha: ${sale['date']?.toString().split('T')[0] ?? 'No disponible'}"),
                    subtitle: Text("Monto total: \$${sale['total']}"),
                    trailing: const Icon(Icons.receipt_long, color: Colors.blueGrey),
                  );
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))],
      ),
    );
  }

  /// Inicializa el diálogo para el registro o edición de datos del cliente.
  void _showCustomerDialog({String? docId, Map<String, dynamic>? data}) {
    final nameController = TextEditingController(text: data?['name'] ?? '');
    final emailController = TextEditingController(text: data?['email'] ?? '');
    final phoneController = TextEditingController(text: data?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId == null ? "Registrar Cliente" : "Actualizar Información"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nombre Completo", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email Institucional", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Teléfono de Contacto", border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'id': docId,
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
              };
              await _repository.addCustomer(payload);
              Navigator.pop(context);
              _refresh();
            },
            child: const Text("Confirmar"),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Base de Datos de Clientes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showCustomerDialog(),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text("Nuevo Registro"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Buscador funcional por criterios de texto.
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Filtrar por nombre...",
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data?.where((doc) {
                  return doc['name'].toString().toLowerCase().contains(searchTerm.toLowerCase());
                }).toList() ?? [];

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        horizontalMargin: 12,
                        columnSpacing: 25,
                        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                        columns: const [
                          DataColumn(label: Text("Nombre", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Contacto", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Historial", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Edición", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: docs.map((doc) => DataRow(cells: [
                          DataCell(Text(doc['name'] ?? '', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(doc['phone'] ?? '', style: const TextStyle(fontSize: 12))),
                          DataCell(IconButton(
                            icon: const Icon(Icons.query_stats, color: Colors.blueGrey, size: 20),
                            onPressed: () => _showCustomerPurchases(doc['email'], doc['name']),
                          )),
                          DataCell(IconButton(
                            icon: const Icon(Icons.edit_note, size: 20, color: Colors.indigo),
                            onPressed: () => _showCustomerDialog(docId: doc['_id'] ?? doc['id'], data: doc),
                          )),
                        ])).toList(),
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
}
