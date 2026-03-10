import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xfff1f5f9),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text("Resumen general de tu negocio", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // STATS GRID
                  isMobile 
                    ? Column(
                        children: [
                          Row(children: [_statCard("\$33,700", "Ventas", "+12.5%", Colors.green), const SizedBox(width: 8), _statCard("156", "Productos", "+8", Colors.green)]),
                          const SizedBox(height: 8),
                          Row(children: [_statCard("1,234", "Clientes", "+23.1%", Colors.green), const SizedBox(width: 8), _statCard("324", "Pedidos", "-2.4%", Colors.red)]),
                        ],
                      )
                    : Row(
                        children: [
                          _statCard("\$33,700", "Ventas Totales", "+12.5%", Colors.green),
                          const SizedBox(width: 16),
                          _statCard("156", "Productos", "+8", Colors.green),
                          const SizedBox(width: 16),
                          _statCard("1,234", "Clientes", "+23.1%", Colors.green),
                          const SizedBox(width: 16),
                          _statCard("324", "Pedidos", "-2.4%", Colors.red),
                        ],
                      ),
                  const SizedBox(height: 24),
                  
                  // CHARTS
                  if (isMobile) ...[
                    _salesChart(),
                    const SizedBox(height: 16),
                    _pieChart(),
                    const SizedBox(height: 16),
                    _barChart(),
                    const SizedBox(height: 16),
                    _recentActivity(),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _salesChart()),
                        const SizedBox(width: 16),
                        Expanded(child: _pieChart()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _barChart()),
                        const SizedBox(width: 16),
                        Expanded(child: _recentActivity()),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String title, String change, Color changeColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.05))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(change, style: TextStyle(color: changeColor, fontWeight: FontWeight.bold, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.05))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _salesChart() {
    return _chartCard("Ventas Mensuales", SizedBox(height: 200, child: LineChart(LineChartData(
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(show: false),
      lineBarsData: [LineChartBarData(isCurved: true, color: Colors.blue, barWidth: 3, spots: const [FlSpot(0, 4500), FlSpot(1, 5200), FlSpot(2, 4800), FlSpot(3, 6100), FlSpot(4, 5900), FlSpot(5, 7200)], dotData: const FlDotData(show: false))],
    ))));
  }

  Widget _pieChart() {
    return _chartCard("Categorías", SizedBox(height: 200, child: PieChart(PieChartData(sections: [
      PieChartSectionData(value: 30, color: Colors.blue, title: "30%", radius: 40),
      PieChartSectionData(value: 25, color: Colors.lightBlue, title: "25%", radius: 40),
      PieChartSectionData(value: 20, color: Colors.amber, title: "20%", radius: 40),
      PieChartSectionData(value: 15, color: Colors.orange, title: "15%", radius: 40),
      PieChartSectionData(value: 10, color: Colors.grey, title: "10%", radius: 40),
    ]))));
  }

  Widget _barChart() {
    return _chartCard("Más Vendidos", SizedBox(height: 200, child: BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: Colors.blue)]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 72, color: Colors.blue)]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 68, color: Colors.blue)]),
        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 54, color: Colors.blue)]),
      ],
    ))));
  }

  Widget _recentActivity() {
    return _chartCard("Actividad Reciente", Column(children: const [
      ListTile(leading: Icon(Icons.shopping_cart, size: 20), title: Text("Venta", style: TextStyle(fontSize: 13)), subtitle: Text("Detergente", style: TextStyle(fontSize: 11)), trailing: Text("5 min", style: TextStyle(fontSize: 10))),
      ListTile(leading: Icon(Icons.warning, size: 20), title: Text("Stock", style: TextStyle(fontSize: 13)), subtitle: Text("Limpiador", style: TextStyle(fontSize: 11)), trailing: Text("1 hr", style: TextStyle(fontSize: 10))),
    ]));
  }
}
