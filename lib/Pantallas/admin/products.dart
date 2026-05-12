import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../models/product_model.dart';

/*
  Pantalla de Gestión de Productos:
  Módulo administrativo para la administración del catálogo de artículos.
  Permite realizar operaciones CRUD (Crear, Leer, Actualizar, Eliminar).
*/
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductRepository _repository = ProductRepository();
  String searchTerm = '';
  late Future<List<Product>> _productsFuture;
  
  // Categorías predefinidas para la clasificación de productos.
  final List<String> _categories = ["Limpieza", "Lavado", "Desinfección", "Otros"];

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  /// Recarga la lista de productos desde el servidor.
  void _refreshProducts() {
    setState(() {
      _productsFuture = _repository.getProducts();
    });
  }

  /// Genera una clave SKU automática basada en la categoría y el conteo de productos.
  String _generateSKU(String category, int count) {
    Map<String, String> prefixes = {
      "Limpieza": "LIM", 
      "Lavado": "LAV", 
      "Desinfección": "DES", 
      "Otros": "OTR"
    };
    String prefix = prefixes[category] ?? "PRO";
    return "$prefix-${(count + 1).toString().padLeft(3, '0')}";
  }

  /// Despliega el formulario para creación o edición de productos.
  void _showProductDialog({Product? product}) {
    final bool isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '0.0');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '0');
    final imgCtrl = TextEditingController(text: product?.image ?? '');
    String selectedCat = product?.category ?? _categories[0];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? "Editar Producto" : "Nuevo Producto"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(nameCtrl, "Nombre"),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _categories.contains(selectedCat) ? selectedCat : _categories[0],
                  decoration: const InputDecoration(labelText: "Categoría", border: OutlineInputBorder()),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCat = val!),
                ),
                const SizedBox(height: 10),
                _buildField(priceCtrl, "Precio (\$)", type: TextInputType.number),
                const SizedBox(height: 10),
                _buildField(stockCtrl, "Stock Inicial", type: TextInputType.number),
                const SizedBox(height: 10),
                _buildField(imgCtrl, "URL de Imagen"),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final all = await _productsFuture;
                
                final p = Product(
                  id: product?.id ?? "", 
                  name: nameCtrl.text,
                  sku: product?.sku ?? _generateSKU(selectedCat, all.length),
                  category: selectedCat,
                  image: imgCtrl.text.isNotEmpty ? imgCtrl.text : "https://via.placeholder.com/150",
                  price: double.tryParse(priceCtrl.text) ?? 0.0,
                  stock: int.tryParse(stockCtrl.text) ?? 0,
                );
                
                // Sincronización con el servidor.
                if (isEdit) await _repository.updateProduct(p.id, p);
                else await _repository.addProduct(p);
                
                if (mounted) { Navigator.pop(context); _refreshProducts(); }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String l, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(labelText: l, border: const OutlineInputBorder(), isDense: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Catálogo Maestro", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showProductDialog(), 
              icon: const Icon(Icons.add, size: 18), 
              label: const Text("Agregar Artículo")
            ),
          ]),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: "Buscar por nombre de producto...",
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 16),
          Expanded(child: FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final products = (snap.data ?? []).where((p) => p.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();
              if (products.isEmpty) return const Center(child: Text("Sin productos registrados"));

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, 
                  childAspectRatio: 0.52, 
                  crossAxisSpacing: 10, 
                  mainAxisSpacing: 10
                ),
                itemCount: products.length,
                itemBuilder: (context, index) => _card(products[index]),
              );
            },
          ))
        ],
      ),
    );
  }

  Widget _card(Product p) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.network(p.image, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Center(child: Icon(Icons.broken_image, color: Colors.grey)))
      )),
      Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(p.sku, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
        Text("\$${p.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
        Text("Stock: ${p.stock}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: p.stock < 10 ? Colors.red : Colors.black87)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () => _showProductDialog(product: p), 
            child: const Icon(Icons.edit_note, size: 20, color: Colors.indigo)
          ),
          GestureDetector(
            onTap: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirmar Acción"),
                  content: Text("¿Desea eliminar el producto ${p.name}?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await _repository.deleteProduct(p.id);
                _refreshProducts();
              }
            }, 
            child: const Icon(Icons.delete_forever, size: 20, color: Colors.red)
          ),
        ])
      ]))
    ]),
  );
}
