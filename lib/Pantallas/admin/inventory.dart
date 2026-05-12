import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../models/product_model.dart';

/*
  Pantalla de Inventario y Stock:
  Módulo encargado de la visualización tabular de las existencias físicas.
  Permite al administrador monitorear los niveles de inventario y el estatus operativo de cada artículo.
*/
class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final ProductRepository _repository = ProductRepository();
  String searchTerm = ''; 
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Inicialización de la carga de datos desde el servicio remoto.
    _refresh();
  }

  /// Recupera la lista actualizada de productos desde el servidor.
  void _refresh() {
    setState(() {
      _productsFuture = _repository.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Control de Inventario", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Monitoreo de existencias físicas y niveles de reabastecimiento.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          
          // Campo de búsqueda con filtrado reactivo por nombre.
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Buscar producto por nombre...",
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 16),
          
          // Representación de datos mediante una tabla con soporte para scroll bidireccional.
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return const Center(child: Text("Error operativo: No se pudo conectar con el almacén central."));
                
                final products = snapshot.data?.where((p) => p.name.toLowerCase().contains(searchTerm.toLowerCase())).toList() ?? [];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 30,
                          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                          columns: const [
                            DataColumn(label: Text("Clave SKU", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Stock Actual", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Categoría", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Estatus", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: products.map((p) => DataRow(cells: [
                            DataCell(Text(p.sku, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataCell(SizedBox(width: 150, child: Text(p.name, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis))),
                            DataCell(Text("${p.stock}", style: const TextStyle(fontSize: 12))),
                            DataCell(Text(p.category, style: const TextStyle(fontSize: 12))),
                            DataCell(_buildStatusBadge(p.stock)),
                          ])).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Genera un indicador visual del estado del inventario.
  Widget _buildStatusBadge(int stock) {
    bool isLow = stock < 10;
    Color color = isLow ? Colors.red : Colors.green;
    String label = isLow ? "Stock Crítico" : "En Existencia";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
