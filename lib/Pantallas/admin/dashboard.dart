import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff1f5f9),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Resumen general de tu negocio",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            /// STATS
            Row(
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

            const SizedBox(height: 32),

            /// CHARTS ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _salesChart()),
                const SizedBox(width: 24),
                Expanded(child: _pieChart()),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _barChart()),
                const SizedBox(width: 24),
                Expanded(child: _recentActivity()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// STAT CARD
  Widget _statCard(
      String value, String title, String change, Color changeColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.04),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(change,
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// LINE CHART
  Widget _salesChart() {
    return _chartCard(
      "Ventas Mensuales",
      SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                spots: const [
                  FlSpot(0, 4500),
                  FlSpot(1, 5200),
                  FlSpot(2, 4800),
                  FlSpot(3, 6100),
                  FlSpot(4, 5900),
                  FlSpot(5, 7200),
                ],
                dotData: const FlDotData(show: false),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// PIE CHART
  Widget _pieChart() {
    return _chartCard(
      "Ventas por Categoría",
      SizedBox(
        height: 250,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                  value: 30, color: Colors.blue, title: "30%"),
              PieChartSectionData(
                  value: 25, color: Colors.lightBlue, title: "25%"),
              PieChartSectionData(
                  value: 20, color: Colors.amber, title: "20%"),
              PieChartSectionData(
                  value: 15, color: Colors.orange, title: "15%"),
              PieChartSectionData(
                  value: 10, color: Colors.grey, title: "10%"),
            ],
          ),
        ),
      ),
    );
  }

  /// BAR CHART
  Widget _barChart() {
    return _chartCard(
      "Productos Más Vendidos",
      SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            barGroups: [
              BarChartGroupData(
                  x: 0,
                  barRods: [BarChartRodData(toY: 85, color: Colors.blue)]),
              BarChartGroupData(
                  x: 1,
                  barRods: [BarChartRodData(toY: 72, color: Colors.blue)]),
              BarChartGroupData(
                  x: 2,
                  barRods: [BarChartRodData(toY: 68, color: Colors.blue)]),
              BarChartGroupData(
                  x: 3,
                  barRods: [BarChartRodData(toY: 54, color: Colors.blue)]),
            ],
          ),
        ),
      ),
    );
  }

  /// RECENT ACTIVITY
  Widget _recentActivity() {
    return _chartCard(
      "Actividad Reciente",
      Column(
        children: const [
          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.blue),
            title: Text("Nueva venta"),
            subtitle: Text("Detergente Líquido - María García"),
            trailing: Text("Hace 5 min"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text("Bajo inventario"),
            subtitle: Text("Limpiador de Pisos (12 unidades)"),
            trailing: Text("Hace 1 hora"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_add, color: Colors.green),
            title: Text("Nuevo cliente"),
            subtitle: Text("Limpieza Express S.A."),
            trailing: Text("Hace 2 horas"),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.04),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}