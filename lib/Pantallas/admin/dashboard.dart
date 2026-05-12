import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/sale_repository.dart';
import '../models/product_model.dart';
import 'package:fl_chart/fl_chart.dart';

/// Vista de Dashboard para el administrador.
/// Muestra estadísticas clave, métricas de rendimiento y alertas de inventario.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ProductRepository _pRepo = ProductRepository();
  final CustomerRepository _cRepo = CustomerRepository();
  final SaleRepository _sRepo = SaleRepository();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return FutureBuilder(
      // Se obtienen los datos de productos, clientes y ventas de forma paralela.
      future: Future.wait([_pRepo.getProducts(), _cRepo.getCustomers(), _sRepo.getSales()]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text("Error al conectar con el servidor central."),
                TextButton(onPressed: () => setState(() {}), child: const Text("Reintentar"))
              ],
            ),
          );
        }

        final List<Product> products = snapshot.data?[0] ?? [];
        final List<dynamic> customers = snapshot.data?[1] ?? [];
        final List<dynamic> sales = snapshot.data?[2] ?? [];

        // Filtrado de productos con stock bajo para alertas.
        final lowStockProducts = products.where((p) => p.stock < 10).toList();
        
        // Cálculo de ingresos totales sumando todas las ventas registradas.
        double totalRevenue = 0;
        for (var sale in sales) {
          totalRevenue += (sale['total'] ?? 0).toDouble();
        }

        return Container(
          color: const Color(0xfff1f5f9),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Resumen de Operaciones", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("Indicadores clave de rendimiento sincronizados", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                
                // Cuadrícula de indicadores principales.
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 2 : 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: isMobile ? 1.4 : 2.2,
                  children: [
                    _statCard("\$${totalRevenue.toStringAsFixed(0)}", "Ingresos Totales", Icons.payments, Colors.green, "Ventas confirmadas"),
                    _statCard("${products.length}", "Productos", Icons.inventory_2, Colors.blue, "Artículos en catálogo"),
                    _statCard("${customers.length}", "Clientes", Icons.people, Colors.orange, "Usuarios registrados"),
                    _statCard("${lowStockProducts.length}", "Stock Bajo", Icons.warning_amber_rounded, Colors.red, "Reabastecimiento urgente"),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Gráfica de evolución de ventas.
                _sectionCard("Tendencia de Ventas Mensuales", SizedBox(
                  height: 200,
                  child: sales.isEmpty 
                    ? const Center(child: Text("Sin registros de ventas históricos"))
                    : LineChart(_mainData(sales)),
                )),

                const SizedBox(height: 24),

                // Lista de productos con stock crítico.
                if (lowStockProducts.isNotEmpty)
                  _sectionCard("Alertas de Inventario", Column(
                    children: lowStockProducts.map((p) => ListTile(
                      dense: true,
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Nivel actual: ${p.stock} unidades"),
                      trailing: const Icon(Icons.priority_high, color: Colors.red, size: 16),
                    )).toList(),
                  )),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye una tarjeta de estadística con descripción del indicador.
  Widget _statCard(String value, String title, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [BoxShadow(blurRadius: 5, color: const Color(0x0D000000))]
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withAlpha(26), radius: 18, child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              Text(title, style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(color: Colors.grey, fontSize: 8), maxLines: 1),
            ],
          )),
        ],
      ),
    );
  }

  /// Contenedor genérico para secciones del dashboard.
  Widget _sectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Divider(),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  /// Procesa los datos de ventas para generar la gráfica lineal.
  LineChartData _mainData(List<dynamic> sales) {
    List<FlSpot> spots = [];
    var sortedSales = List.from(sales);
    sortedSales.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
    
    for (int i = 0; i < sortedSales.length; i++) {
      spots.add(FlSpot(i.toDouble(), (sortedSales[i]['total'] ?? 0).toDouble()));
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: Colors.blue.withAlpha(20)),
        ),
      ],
    );
  }
}
