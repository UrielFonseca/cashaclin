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
    final nameController =
    TextEditingController(text: customer?.name ?? '');
    final emailController =
    TextEditingController(text: customer?.email ?? '');
    final phoneController =
    TextEditingController(text: customer?.phone ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(customer == null ? "Nuevo Cliente" : "Editar Cliente"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                const InputDecoration(labelText: "Nombre Completo"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration:
                const InputDecoration(labelText: "Correo Electrónico"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration:
                const InputDecoration(labelText: "Teléfono"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final newCustomer = Customer(
                id: customer?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
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
                  final index =
                  customers.indexWhere((c) => c.id == customer.id);
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

  void _deleteCustomer(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("¿Eliminar este cliente?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () {
                setState(() {
                  customers.removeWhere((c) => c.id == id);
                });
                Navigator.pop(context);
              },
              child: const Text("Eliminar")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCustomers = customers.length;
    final totalRevenue =
    customers.fold<double>(0, (sum, c) => sum + c.totalSpent);
    final totalOrders =
    customers.fold<int>(0, (sum, c) => sum + c.totalOrders);
    final avgOrderValue =
    totalOrders == 0 ? 0 : totalRevenue / totalOrders;

    return Container(
      color: const Color(0xfff3f4f6),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clientes",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Gestiona tu base de clientes"),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCustomerDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Agregar Cliente"),
              )
            ],
          ),

          const SizedBox(height: 24),

          /// Stats
          Row(
            children: [
              _statCard("Total Clientes", totalCustomers.toString()),
              const SizedBox(width: 16),
              _statCard("Ingresos Totales",
                  "\$${totalRevenue.toStringAsFixed(2)}"),
              const SizedBox(width: 16),
              _statCard("Ticket Promedio",
                  "\$${avgOrderValue.toStringAsFixed(2)}"),
            ],
          ),

          const SizedBox(height: 24),

          /// Search
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Buscar clientes...",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchTerm = value;
              });
            },
          ),

          const SizedBox(height: 24),

          /// Table
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Cliente")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Teléfono")),
                  DataColumn(label: Text("Pedidos")),
                  DataColumn(label: Text("Total")),
                  DataColumn(label: Text("Acciones")),
                ],
                rows: filteredCustomers.map((customer) {
                  return DataRow(cells: [
                    DataCell(Text(customer.name)),
                    DataCell(Text(customer.email)),
                    DataCell(Text(customer.phone)),
                    DataCell(Text(customer.totalOrders.toString())),
                    DataCell(Text(
                        "\$${customer.totalSpent.toStringAsFixed(2)}")),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showCustomerDialog(customer: customer),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _deleteCustomer(customer.id),
                        ),
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

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}