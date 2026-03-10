import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/customers_data.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  late List<Customer> customers;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    customers = List.from(mockCustomers);
  }

  List<Customer> get filteredCustomers {
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          customer.email.toLowerCase().contains(searchTerm.toLowerCase()) ||
          customer.phone.contains(searchTerm);
    }).toList();
  }

  void _showCustomerDialog({Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(customer == null ? "Nuevo Cliente" : "Editar Cliente"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameController, "Nombre"),
              _field(emailController, "Email"),
              _field(phoneController, "Teléfono"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final newCustomer = Customer(
                id: customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                totalOrders: customer?.totalOrders ?? 0,
                totalSpent: customer?.totalSpent ?? 0,
                joinDate: customer?.joinDate ?? DateTime.now(),
              );
              setState(() {
                if (customer == null) {
                  customers.add(newCustomer);
                } else {
                  final index = customers.indexWhere((c) => c.id == customer.id);
                  customers[index] = newCustomer;
                }
              });
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Clientes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCustomerDialog(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Agregar Cliente"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                    ),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Clientes", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(onPressed: () => _showCustomerDialog(), icon: const Icon(Icons.add), label: const Text("Agregar Cliente")),
                ],
              ),
          const SizedBox(height: 20),
          
          // Stats Row
          isMobile 
            ? Column(
                children: [
                  _statItem(Icons.people, "Total", customers.length.toString(), Colors.blue),
                  const SizedBox(height: 8),
                  _statItem(Icons.monetization_on, "Ventas", "\$${customers.fold<double>(0, (s, c) => s + c.totalSpent).toStringAsFixed(0)}", Colors.green),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _statItem(Icons.people, "Total Clientes", customers.length.toString(), Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _statItem(Icons.monetization_on, "Ingresos Totales", "\$${customers.fold<double>(0, (s, c) => s + c.totalSpent).toStringAsFixed(0)}", Colors.green)),
                ],
              ),
          
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: "Buscar...",
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 20),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DataTable(
                horizontalMargin: 12,
                columnSpacing: 15,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(label: Text("Nombre", style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text("Tel", style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text("Acciones", style: TextStyle(fontSize: 12))),
                ],
                rows: filteredCustomers.map((customer) {
                  return DataRow(cells: [
                    DataCell(SizedBox(width: 100, child: Text(customer.name, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))),
                    DataCell(Text(customer.phone, style: const TextStyle(fontSize: 11))),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showCustomerDialog(customer: customer)),
                        IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => setState(() => customers.removeWhere((c) => c.id == customer.id))),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 18, child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ])
        ],
      ),
    );
  }
}
