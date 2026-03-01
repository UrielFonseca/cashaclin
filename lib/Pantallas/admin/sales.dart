import 'package:flutter/material.dart';

class Sale {
  final String id;
  final String customer;
  final String date;
  final double total;
  final String status;

  Sale({
    required this.id,
    required this.customer,
    required this.date,
    required this.total,
    required this.status,
  });
}

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final List<Sale> sales = [
    Sale(id: "ORD-001", customer: "Juan Perez", date: "2023-10-25", total: 1500.0, status: "Completada"),
    Sale(id: "ORD-002", customer: "Maria Garcia", date: "2023-10-26", total: 850.50, status: "Pendiente"),
    Sale(id: "ORD-003", customer: "Carlos Lopez", date: "2023-10-26", total: 2100.0, status: "Completada"),
    Sale(id: "ORD-004", customer: "Ana Martinez", date: "2023-10-27", total: 450.0, status: "Cancelada"),
    Sale(id: "ORD-005", customer: "Roberto Sanchez", date: "2023-10-27", total: 1200.0, status: "Pendiente"),
  ];

  @override
  Widget build(BuildContext context) {
    final completedSales = sales.where((s) => s.status == "Completada").length;
    final pendingSales = sales.where((s) => s.status == "Pendiente").length;
    final totalRevenue = sales.where((s) => s.status == "Completada").fold(0.0, (sum, s) => sum + s.total);

    return Container(
      color: const Color(0xfff3f4f6),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ventas", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              _statCard("Ventas Completadas", completedSales.toString(), Colors.green),
              const SizedBox(width: 16),
              _statCard("Ventas Pendientes", pendingSales.toString(), Colors.orange),
              const SizedBox(width: 16),
              _statCard("Total Ingresos", "\$${totalRevenue.toStringAsFixed(2)}", Colors.blue),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("ID Orden")),
                    DataColumn(label: Text("Cliente")),
                    DataColumn(label: Text("Fecha")),
                    DataColumn(label: Text("Total")),
                    DataColumn(label: Text("Estado")),
                  ],
                  rows: sales.map((sale) {
                    return DataRow(cells: [
                      DataCell(Text(sale.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(sale.customer)),
                      DataCell(Text(sale.date)),
                      DataCell(Text("\$${sale.total.toStringAsFixed(2)}")),
                      DataCell(_statusChip(sale.status)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "Completada": color = Colors.green; break;
      case "Pendiente": color = Colors.orange; break;
      case "Cancelada": color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
