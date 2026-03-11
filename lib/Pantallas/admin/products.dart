import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');
  String searchTerm = '';

  void _showProductDialog({Product? product, String? docId}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final skuController = TextEditingController(text: product?.sku ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '0.0');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '0');
    final imageController = TextEditingController(text: product?.image ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? "Nuevo Producto" : "Editar Producto"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameController, "Nombre"),
              _field(skuController, "SKU"),
              _field(categoryController, "Categoría"),
              _field(descController, "Descripción", maxLines: 2),
              _field(priceController, "Precio", type: TextInputType.number),
              _field(stockController, "Stock", type: TextInputType.number),
              _field(imageController, "URL Imagen"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () async {
            if (nameController.text.isEmpty) return;
            final data = {
              'name': nameController.text,
              'sku': skuController.text,
              'category': categoryController.text,
              'description': descController.text,
              'price': double.tryParse(priceController.text) ?? 0.0,
              'stock': int.tryParse(stockController.text) ?? 0,
              'image': imageController.text,
            };
            if (docId == null) await productsRef.add(data);
            else await productsRef.doc(docId).update(data);
            if (mounted) Navigator.pop(context);
          }, child: const Text("Guardar"))
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String l, {int maxLines = 1, TextInputType type = TextInputType.text}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(controller: c, maxLines: maxLines, keyboardType: type, decoration: InputDecoration(labelText: l, border: const OutlineInputBorder(), isDense: true)),
  );

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Productos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(onPressed: () => _showProductDialog(), icon: const Icon(Icons.add, size: 18), label: const Text("Nuevo")),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search, size: 20), hintText: "Buscar...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), isDense: true),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: productsRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.where((d) => d['name'].toString().toLowerCase().contains(searchTerm.toLowerCase())).toList();
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobile ? 180 : 250,
                  childAspectRatio: isMobile ? 0.52 : 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final d = docs[index];
                  final p = Product(id: d.id, name: d['name'], sku: d['sku'], category: d['category'], description: d['description'], price: d['price'].toDouble(), stock: d['stock'], image: d['image']);
                  return _card(p, d.id);
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget _card(Product p, String id) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(p.image, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Center(child: Icon(Icons.image, color: Colors.grey))))),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("\$${p.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Stock: ${p.stock}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Row(
                      children: [
                        GestureDetector(onTap: () => _showProductDialog(product: p, docId: id), child: const Icon(Icons.edit, size: 16, color: Colors.blue)),
                        const SizedBox(width: 10),
                        GestureDetector(onTap: () => productsRef.doc(id).delete(), child: const Icon(Icons.delete, size: 16, color: Colors.red)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
