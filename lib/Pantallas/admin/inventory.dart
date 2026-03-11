import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  String searchTerm = '';
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');

  void updateStock(String docId, int currentStock, int change) {
    productsRef.doc(docId).update({
      'stock': (currentStock + change).clamp(0, 9999),
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return StreamBuilder<QuerySnapshot>(
      stream: productsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs.where((doc) {
          return doc['name'].toString().toLowerCase().contains(searchTerm.toLowerCase());
        }).toList();

        final totalUnits = snapshot.data!.docs.fold<int>(0, (sum, doc) => sum + (doc['stock'] as int));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Inventario Real", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Sincronizado con la tienda", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              
              isMobile 
                ? Column(
                    children: [
                      _statItem(Icons.inventory_2, "Unidades Totales", totalUnits.toString(), Colors.blue),
                      const SizedBox(height: 8),
                      _statItem(Icons.category, "SKUs Activos", docs.length.toString(), Colors.orange),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _statItem(Icons.inventory_2, "Unidades Totales", totalUnits.toString(), Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _statItem(Icons.category, "SKUs Activos", docs.length.toString(), Colors.orange)),
                    ],
                  ),
              
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: "Buscar producto...",
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: DataTable(
                    horizontalMargin: 12,
                    columnSpacing: 20,
                    headingRowHeight: 50,
                   // dataRowHeight: 60,
                    columns: const [
                      DataColumn(label: Text("Producto", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Stock", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Ajuste", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    ],
                    rows: docs.map((doc) {
                      final int stock = doc['stock'];
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 100, child: Text(doc['name'], style: const TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis))),
                        DataCell(Text("$stock", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: stock <= 10 ? Colors.red : Colors.black87))),
                        DataCell(Row(
                          children: [
                            _actionBtn("-", () => updateStock(doc.id, stock, -1), const Color(0xFFFFEBEE), Colors.red),
                            const SizedBox(width: 8),
                            _actionBtn("+", () => updateStock(doc.id, stock, 1), const Color(0xFFE3F2FD), Colors.blue),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ])
        ],
      ),
    );
  }

  Widget _actionBtn(String text, VoidCallback tap, Color bg, Color textCol) => InkWell(
    onTap: tap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(text, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 18))),
    ),
  );
}
