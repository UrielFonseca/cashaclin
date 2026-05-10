import 'package:flutter/material.dart';
import '../../repositories/sale_repository.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final SaleRepository _repository = SaleRepository();
  late Future<List<Map<String, dynamic>>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _salesFuture = _repository.getSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _salesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final docs = snapshot.data ?? [];
        final completedSales = docs.where((s) => s['status'] == 'Completada').length;
        double totalRevenue = 0;
        for (var doc in docs) {
          totalRevenue += (doc['total'] ?? 0).toDouble();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ventas Reales", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Historial sincronizado vía API", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              
              isMobile 
                ? Column(
                    children: [
                      _statItem(Icons.check_circle, "Completas", completedSales.toString(), Colors.green),
                      const SizedBox(height: 8),
                      _statItem(Icons.monetization_on, "Ingresos", "\$${totalRevenue.toStringAsFixed(0)}", Colors.blue),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _statItem(Icons.check_circle, "Ventas Completadas", completedSales.toString(), Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _statItem(Icons.monetization_on, "Total Ingresos", "\$${totalRevenue.toStringAsFixed(0)}", Colors.blue)),
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
                    dataRowHeight: 55,
                    columns: const [
                      DataColumn(label: Text("Cliente", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Total", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Estado", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    ],
                    rows: docs.map((doc) {
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 100, child: Text(doc['customerName'] ?? 'Anónimo', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))),
                        DataCell(Text("\$${(doc['total'] ?? 0).toStringAsFixed(0)}", style: const TextStyle(fontSize: 11))),
                        DataCell(_statusBadge(doc['status'] ?? 'Pendiente')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(IconData icon, String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 5)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withAlpha(26), radius: 18, child: Icon(icon, color: color, size: 18)),
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
    Color col = status == "Completada" ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: col.withAlpha(26), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
