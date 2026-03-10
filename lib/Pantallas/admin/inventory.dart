import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/products_data.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late List<Product> products;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    products = List.from(mockProducts);
  }

  List<Product> get filteredProducts {
    return products.where((product) =>
    product.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
        product.sku.toLowerCase().contains(searchTerm.toLowerCase())).toList();
  }

  void updateStock(String id, int change) {
    setState(() {
      final index = products.indexWhere((p) => p.id == id);
      if (index != -1) {
        products[index].stock = (products[index].stock + change).clamp(0, 9999);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final totalUnits = products.fold<int>(0, (sum, p) => sum + p.stock);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Inventario", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Control de stock", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          
          isMobile 
            ? Column(
                children: [
                  _statItem(Icons.inventory_2, "Total Unidades", totalUnits.toString(), Colors.blue),
                  const SizedBox(height: 8),
                  _statItem(Icons.category, "Productos", products.length.toString(), Colors.orange),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _statItem(Icons.inventory_2, "Total Unidades", totalUnits.toString(), Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _statItem(Icons.category, "Productos", products.length.toString(), Colors.orange)),
                ],
              ),
          
          const SizedBox(height: 24),
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
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 5)],
              ),
              child: DataTable(
                horizontalMargin: 12,
                columnSpacing: 20,
                headingRowHeight: 50,
                dataRowHeight: 60, 
                columns: const [
                  DataColumn(label: Text("Prod", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("SKU", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Stock", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Acción", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                ],
                rows: filteredProducts.map((product) {
                  return DataRow(cells: [
                    DataCell(SizedBox(width: 80, child: Text(product.name, style: const TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis))),
                    DataCell(Text(product.sku, style: const TextStyle(fontSize: 11))),
                    DataCell(Text("${product.stock}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: product.stock <= 10 ? Colors.red : Colors.black))),
                    DataCell(Row(
                      children: [
                        _actionBtn("-", () => updateStock(product.id, -1), Colors.red.shade100, Colors.red),
                        const SizedBox(width: 8),
                        _actionBtn("+", () => updateStock(product.id, 1), Colors.blue.shade100, Colors.blue),
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
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 5)]
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(26), 
            radius: 18, 
            child: Icon(icon, color: color, size: 18)
          ),
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

  Widget _actionBtn(String text, VoidCallback tap, Color bg, Color textCol) => InkWell(
    onTap: tap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Center(child: Text(text, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 16))),
    ),
  );
}
