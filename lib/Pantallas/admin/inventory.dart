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

  List<Product> get lowStockProducts =>
      products.where((p) => p.stock <= 15).toList();

  void updateStock(String id, int change) {
    setState(() {
      final index = products.indexWhere((p) => p.id == id);
      if (index != -1) {
        products[index].stock =
            (products[index].stock + change).clamp(0, 9999);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalUnits =
    products.fold<int>(0, (sum, p) => sum + p.stock);

    return Container(
      color: const Color(0xfff3f4f6),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          const Text("Inventario",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Control de stock y movimientos"),
          const SizedBox(height: 24),

          /// Stats
          Row(
            children: [
              _statCard("Total Unidades", totalUnits.toString()),
              const SizedBox(width: 16),
              _statCard("Productos Activos", products.length.toString()),
              const SizedBox(width: 16),
              _statCard("Stock Bajo", lowStockProducts.length.toString(),
                  color: Colors.red),
            ],
          ),

          const SizedBox(height: 24),

          /// Search
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Buscar productos...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(label: Text("Producto")),
                    DataColumn(label: Text("SKU")),
                    DataColumn(label: Text("Stock")),
                    DataColumn(label: Text("Estado")),
                    DataColumn(label: Text("Acciones")),
                  ],
                  rows: filteredProducts.map((product) {
                    return DataRow(cells: [
                      DataCell(Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.image,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 45,
                                height: 45,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      )),
                      DataCell(Text(product.sku)),
                      DataCell(Text("${product.stock}")),
                      DataCell(_stockStatus(product.stock)),
                      DataCell(Row(
                        children: [
                          _actionButton("-", () => updateStock(product.id, -1), color: Colors.red.shade400),
                          const SizedBox(width: 8),
                          _actionButton("+", () => updateStock(product.id, 1), color: Colors.blue.shade400),
                        ],
                      )),
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

  Widget _statCard(String title, String value, {Color color = Colors.blue}) {
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

  Widget _stockStatus(int stock) {
    if (stock > 20) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
        child: Text("Suficiente", style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
        child: Text("Bajo", style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
      );
    }
  }

  Widget _actionButton(String text, VoidCallback onPressed, {required Color color}) {
    return SizedBox(
      width: 35,
      height: 35,
      child: IconButton(
        onPressed: onPressed,
        icon: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
