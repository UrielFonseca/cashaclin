import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/sale_repository.dart';
import 'package:fl_chart/fl_chart.dart';

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
      future: Future.wait([_pRepo.getProducts(), _cRepo.getCustomers(), _sRepo.getSales()]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final products = snapshot.data?[0] ?? [];
        final customers = snapshot.data?[1] ?? [];
        final sales = snapshot.data?[2] ?? [];

        double totalRevenue = 0;
        for (var sale in sales) { totalRevenue += (sale['total'] ?? 0).toDouble(); }

        return Container(
          color: const Color(0xfff1f5f9),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Panel de Control", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text("Resumen sincronizado vía API REST", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                
                isMobile 
                ? Column(children: [
                    Row(children: [_statCard("\$${totalRevenue.toStringAsFixed(0)}", "Ventas", Icons.monetization_on, Colors.green), const SizedBox(width: 8), _statCard("${products.length}", "Stock", Icons.inventory, Colors.blue)]),
                    const SizedBox(height: 8),
                    Row(children: [_statCard("${customers.length}", "Clientes", Icons.people, Colors.orange), const SizedBox(width: 8), _statCard("${sales.length}", "Pedidos", Icons.shopping_bag, Colors.purple)]),
                  ])
                : Row(children: [
                    _statCard("\$${totalRevenue.toStringAsFixed(0)}", "Ingresos", Icons.monetization_on, Colors.green),
                    const SizedBox(width: 16),
                    _statCard("${products.length}", "Artículos", Icons.inventory, Colors.blue),
                    const SizedBox(width: 16),
                    _statCard("${customers.length}", "Clientes", Icons.people, Colors.orange),
                    const SizedBox(width: 16),
                    _statCard("${sales.length}", "Pedidos", Icons.shopping_bag, Colors.purple),
                  ]),
                
                const SizedBox(height: 24),
                const Text("Actividad Reciente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                if (sales.isEmpty) const Text("No hay datos disponibles en la API."),
                ...sales.reversed.take(5).map((s) => ListTile(
                  leading: const Icon(Icons.receipt, color: Colors.blue),
                  title: Text(s['customerName'] ?? 'Anon'),
                  subtitle: Text("Total: \$${s['total']}"),
                  trailing: const Text("Completado", style: TextStyle(color: Colors.green, fontSize: 11)),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String value, String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(blurRadius: 5, color: const Color(0x0D000000))]),
        child: Row(children: [
          CircleAvatar(backgroundColor: color.withAlpha(26), radius: 18, child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}
