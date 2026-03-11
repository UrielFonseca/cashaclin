import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> productSnap) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('customers').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> customerSnap) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance.collection('sales').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> salesSnap) {
                if (!productSnap.hasData || !customerSnap.hasData || !salesSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final int totalProducts = productSnap.data!.docs.length;
                final int totalCustomers = customerSnap.data!.docs.length;
                final int totalSalesCount = salesSnap.data!.docs.length;
                double totalRevenue = 0;
                for (var doc in salesSnap.data!.docs) {
                  totalRevenue += (doc['total'] ?? 0).toDouble();
                }

                return Container(
                  color: const Color(0xfff1f5f9),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Dashboard Real", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text("Datos sincronizados con la nube", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              isMobile 
                                ? Column(
                                    children: [
                                      Row(children: [_statCard("\$${totalRevenue.toStringAsFixed(0)}", "Ingresos", Icons.monetization_on, Colors.green), const SizedBox(width: 8), _statCard("$totalProducts", "Productos", Icons.inventory, Colors.blue)]),
                                      const SizedBox(height: 8),
                                      Row(children: [_statCard("$totalCustomers", "Clientes", Icons.people, Colors.orange), const SizedBox(width: 8), _statCard("$totalSalesCount", "Ventas", Icons.shopping_bag, Colors.purple)]),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      _statCard("\$${totalRevenue.toStringAsFixed(0)}", "Ingresos Totales", Icons.monetization_on, Colors.green),
                                      const SizedBox(width: 16),
                                      _statCard("$totalProducts", "Productos Activos", Icons.inventory, Colors.blue),
                                      const SizedBox(width: 16),
                                      _statCard("$totalCustomers", "Clientes Registrados", Icons.people, Colors.orange),
                                      const SizedBox(width: 16),
                                      _statCard("$totalSalesCount", "Pedidos Realizados", Icons.shopping_bag, Colors.purple),
                                    ],
                                  ),
                              const SizedBox(height: 24),
                              
                              // GRÁFICA DE VENTAS
                              _chartCard("Tendencia de Ventas", SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 4,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(show: true, color: Colors.blue.withAlpha(20)),
                                        spots: _getSalesSpots(salesSnap.data!.docs),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              const SizedBox(height: 16),
                              _recentSalesList(salesSnap.data!.docs),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<FlSpot> _getSalesSpots(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return [const FlSpot(0, 0)];
    List<FlSpot> spots = [];
    for (int i = 0; i < docs.length; i++) {
      spots.add(FlSpot(i.toDouble(), (docs[i]['total'] ?? 0).toDouble()));
    }
    return spots;
  }

  Widget _statCard(String value, String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 5, color: const Color(0x0D000000))],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withAlpha(26), radius: 18, child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 9), maxLines: 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _recentSalesList(List<QueryDocumentSnapshot> sales) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Últimos Pedidos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          if (sales.isEmpty) const Text("No hay ventas registradas."),
          ...sales.reversed.take(5).map((sale) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.person, size: 18, color: Colors.blue)),
            title: Text(sale['customerName'] ?? 'Anónimo', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text("\$${sale['total'].toStringAsFixed(0)}", style: const TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withAlpha(20), borderRadius: BorderRadius.circular(8)),
              child: const Text("Pagado", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )),
        ],
      ),
    );
  }
}
