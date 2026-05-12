import 'package:flutter/material.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/sale_repository.dart';

/*
  Pantalla de Gestión de Clientes:
  Módulo administrativo diseñado para la administración de la base de datos de usuarios.
  Permite realizar el registro, actualización, eliminación y consulta de historial de consumo.
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

  /// Sincroniza la vista con los datos más recientes del servidor.
  void _refresh() {
    setState(() {
      _customersFuture = _repository.getCustomers();
    });
  }

  /*
    Consulta de Historial:
    Busca de forma reactiva todas las transacciones en la nube filtradas por el correo
    electrónico del cliente seleccionado.
  */
  void _showCustomerPurchases(String email, String name) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Historial de Consumo - $name"),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _saleRepository.getSales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) 
                return const Center(child: CircularProgressIndicator());
              
              // Filtrado dinámico de pedidos asociados al usuario.
              final sales = snapshot.data?.where((s) => s['customerEmail'] == email).toList() ?? [];
              
              if (sales.isEmpty) return const Text("No se registran transacciones para este perfil.");

              return ListView.builder(
                shrinkWrap: true,
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ListTile(
                    leading: const Icon(Icons.receipt, color: Colors.blueGrey),
                    title: Text("Orden: ${sale['date']?.toString().split('T')[0] ?? 'N/A'}"),
                    subtitle: Text("Importe: \$${sale['total']}"),
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

  /*
    Gestión de Información de Cliente:
    Diferencia entre la creación de un nuevo registro y la actualización de uno existente
    para evitar la duplicidad de datos en el servidor.
  */
  void _showCustomerDialog({String? docId, Map<String, dynamic>? data}) {
    final bool isEdit = docId != null;
    final nameController = TextEditingController(text: data?['name'] ?? '');
    final emailController = TextEditingController(text: data?['email'] ?? '');
    final phoneController = TextEditingController(text: data?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Actualizar Registro" : "Registrar Cliente"),
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
              if (nameController.text.isEmpty || emailController.text.isEmpty) return;
              
              final payload = {
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
              };

              // Implementación de lógica PUT para edición y POST para creación.
              if (isEdit) {
                await _repository.updateCustomer(docId, payload);
              } else {
                await _repository.addCustomer(payload);
              }
              
              if (mounted) {
                Navigator.pop(context);
                _refresh();
              }
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
              const Text("Directorio de Clientes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showCustomerDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Nuevo Registro"),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Motor de búsqueda local basado en el nombre del cliente.
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Buscar por nombre...",
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
                  return (doc['name'] ?? '').toString().toLowerCase().contains(searchTerm.toLowerCase());
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
                          DataColumn(label: Text("Teléfono", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Historial", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: docs.map((doc) {
                          final String id = doc['_id']?.toString() ?? doc['id']?.toString() ?? '';
                          return DataRow(cells: [
                            DataCell(Text(doc['name'] ?? '', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(doc['phone'] ?? '', style: const TextStyle(fontSize: 12))),
                            DataCell(IconButton(
                              icon: const Icon(Icons.history_edu, color: Colors.blueGrey, size: 18),
                              onPressed: () => _showCustomerPurchases(doc['email'], doc['name']),
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.indigo),
                                  onPressed: () => _showCustomerDialog(docId: id, data: doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                                  onPressed: () async {
                                    await _repository.deleteCustomer(id);
                                    _refresh();
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
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
