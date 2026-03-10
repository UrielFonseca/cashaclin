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
    Sale(id: "ORD-002", customer: "Maria Garcia", date: "2023-10-26", total: 850.5, status: "Pendiente"),
    Sale(id: "ORD-003", customer: "Carlos Lopez", date: "2023-10-26", total: 2100.0, status: "Completada"),
    Sale(id: "ORD-004", customer: "Ana Martinez", date: "2023-10-27", total: 450.0, status: "Cancelada"),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ventas", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          isMobile 
            ? Column(
                children: [
                  _statItem(Icons.check_circle, "Completas", "3", Colors.green),
                  const SizedBox(height: 8),
                  _statItem(Icons.pending, "Pendientes", "1", Colors.orange),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _statItem(Icons.check_circle, "Ventas Completas", "3", Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _statItem(Icons.pending, "Ventas Pendientes", "1", Colors.orange)),
                ],
              ),
          
          const SizedBox(height: 24),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DataTable(
                horizontalMargin: 12,
                columnSpacing: 15,
                headingRowHeight: 45,
                columns: const [
                  DataColumn(label: Text("ID", style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text("Cliente", style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text("Total", style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text("Estado", style: TextStyle(fontSize: 12))),
                ],
                rows: sales.map((sale) {
                  return DataRow(cells: [
                    DataCell(Text(sale.id, style: const TextStyle(fontSize: 11))),
                    DataCell(SizedBox(width: 80, child: Text(sale.customer, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))),
                    DataCell(Text("\$${sale.total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 11))),
                    DataCell(_statusBadge(sale.status)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          )
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color col = status == "Completada" ? Colors.green : (status == "Pendiente" ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
