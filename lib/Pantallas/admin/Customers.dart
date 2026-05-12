import 'package:flutter/material.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/sale_repository.dart';

/*
  Pantalla de Gestión de Clientes:
  Permite al administrador visualizar la base de datos de clientes, 
  editar sus perfiles y consultar su historial de compras individual.
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

  /// Recupera la lista de clientes desde el repositorio.
  void _refresh() {
    setState(() {
      _customersFuture = _repository.getCustomers();
    });
  }

  /// Despliega un modal con la lista de transacciones realizadas por el cliente.
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
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              
              // Filtrado de ventas por el correo electrónico del cliente seleccionado.
              final sales = snapshot.data?.where((s) => s['customerEmail'] == email).toList() ?? [];
              
              if (sales.isEmpty) return const Text("No se registraron transacciones para este perfil.");

              return ListView.builder(
                shrinkWrap: true,
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ListTile(
                    title: Text("Fecha de Pedido: ${sale['date']?.toString().split('T')[0] ?? 'N/A'}"),
                    subtitle: Text("Monto Final: \$${sale['total']}"),
                    trailing: const Icon(Icons.receipt, color: Colors.blueGrey),
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

  /// Abre el formulario para registrar un nuevo cliente o modificar uno existente.
  void _showCustomerDialog({String? docId, Map<String, dynamic>? data}) {
    final nameController = TextEditingController(text: data?['name'] ?? '');
    final emailController = TextEditingController(text: data?['email'] ?? '');
    final phoneController = TextEditingController(text: data?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId == null ? "Registrar Nuevo Cliente" : "Actualizar Información"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nombre Completo", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo Electrónico", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Número Telefónico", border: OutlineInputBorder())),
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
            child: const Text("Guardar Cambios"),
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
              const Text("Gestión de Clientes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showCustomerDialog(),
                icon: const Icon(Icons.person_add),
                label: const Text("Nuevo Cliente"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Buscador dinámico por nombre.
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
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text("Nombre")),
                          DataColumn(label: Text("Teléfono")),
                          DataColumn(label: Text("Historial")),
                          DataColumn(label: Text("Acciones")),
                        ],
                        rows: docs.map((doc) => DataRow(cells: [
                          DataCell(Text(doc['name'] ?? '', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(doc['phone'] ?? '', style: const TextStyle(fontSize: 12))),
                          DataCell(IconButton(
                            icon: const Icon(Icons.manage_search, color: Colors.blueGrey, size: 20),
                            onPressed: () => _showCustomerPurchases(doc['email'], doc['name']),
                          )),
                          DataCell(IconButton(
                            icon: const Icon(Icons.edit_note, size: 18, color: Colors.indigo),
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
