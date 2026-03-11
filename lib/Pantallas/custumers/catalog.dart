import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class CatalogPage extends StatefulWidget {
  final Function(Product, int) onAddToCart;
  const CatalogPage({super.key, required this.onAddToCart});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String searchTerm = '';
  String selectedCategory = 'Todos';
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    final categories = ['Todos', 'Lavandería', 'Pisos', 'Desinfección'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Catálogo de Productos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const Text("Precios especiales minoristas/mayoristas", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar...",
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: selectedCategory == cat,
                  onSelected: (val) => setState(() => selectedCategory = cat),
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(color: selectedCategory == cat ? Colors.white : Colors.black87),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final products = snapshot.data!.docs.where((doc) {
                  final matchesSearch = doc['name'].toString().toLowerCase().contains(searchTerm.toLowerCase());
                  final matchesCat = selectedCategory == 'Todos' || doc['category'] == selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final product = Product(
                      id: doc.id,
                      name: doc['name'],
                      sku: doc['sku'],
                      category: doc['category'],
                      description: doc['description'],
                      price: doc['price'].toDouble(),
                      stock: doc['stock'],
                      image: doc['image'],
                    );
                    return _productCard(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product product) {
    int quantity = 1;
    return StatefulBuilder(
      builder: (context, setStateCard) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(product.image, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.category.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("\$${product.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _qtyBtn(Icons.remove, () => setStateCard(() => quantity = quantity > 1 ? quantity - 1 : 1)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text("$quantity", style: const TextStyle(fontSize: 12))),
                            _qtyBtn(Icons.add, () => setStateCard(() => quantity++)),
                          ],
                        ),
                        SizedBox(
                          width: 32, height: 32,
                          child: IconButton.filled(
                            padding: EdgeInsets.zero,
                            onPressed: product.stock > 0 ? () => widget.onAddToCart(product, quantity) : null,
                            icon: Icon(product.stock > 0 ? Icons.add_shopping_cart : Icons.block, size: 16),
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback tap) => InkWell(
    onTap: tap,
    child: Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 14),
    ),
  );
}
