import 'package:flutter/material.dart';
import '../../repositories/customer_repository.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final CustomerRepository _repository = CustomerRepository();
  String searchTerm = '';
  late Future<List<Map<String, dynamic>>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _customersFuture = _repository.getCustomers();
    });
  }

  void _showCustomerDialog({String? docId, Map<String, dynamic>? data}) {
    final nameController = TextEditingController(text: data?['name'] ?? '');
    final emailController = TextEditingController(text: data?['email'] ?? '');
    final phoneController = TextEditingController(text: data?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId == null ? "Nuevo Cliente" : "Editar Cliente"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameController, "Nombre Completo"),
              _field(emailController, "Correo Electrónico"),
              _field(phoneController, "Teléfono"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
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
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Clientes",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCustomerDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Nuevo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: "Buscar cliente...",
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Text("No hay clientes (API)");

                final docs = snapshot.data!.where((doc) {
                  return doc['name'].toString().toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  );
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 32,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DataTable(
                        horizontalMargin: 12,
                        columnSpacing: 15,
                        headingRowHeight: 45,
                        columns: const [
                          DataColumn(
                            label: Text(
                              "Nombre",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Teléfono",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Acción",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: docs
                            .map(
                              (doc) => DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        doc['name'],
                                        style: const TextStyle(fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      doc['phone'] ?? '',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _showCustomerDialog(
                                        docId: doc['id'],
                                        data: doc,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
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
