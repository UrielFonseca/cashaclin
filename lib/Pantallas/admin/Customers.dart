import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final CollectionReference customersRef = FirebaseFirestore.instance.collection('customers');
  String searchTerm = '';

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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'lastUpdate': FieldValue.serverTimestamp(),
              };
              if (docId == null) {
                await customersRef.add(payload);
              } else {
                await customersRef.doc(docId).update(payload);
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: ctrl, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
  );

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Clientes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showCustomerDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Nuevo"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: "Buscar cliente...",
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: customersRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final docs = snapshot.data!.docs.where((doc) {
                return doc['name'].toString().toLowerCase().contains(searchTerm.toLowerCase());
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: DataTable(
                    horizontalMargin: 12,
                    columnSpacing: 15,
                    headingRowHeight: 45,
                    columns: const [
                      DataColumn(label: Text("Nombre", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Teléfono", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Acción", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    ],
                    rows: docs.map((doc) => DataRow(cells: [
                      DataCell(SizedBox(width: 100, child: Text(doc['name'], style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))),
                      DataCell(Text(doc['phone'], style: const TextStyle(fontSize: 11))),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 16, color: Colors.blue), onPressed: () => _showCustomerDialog(docId: doc.id, data: doc.data() as Map<String, dynamic>)),
                          IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () => customersRef.doc(doc.id).delete()),
                        ],
                      )),
                    ])).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
