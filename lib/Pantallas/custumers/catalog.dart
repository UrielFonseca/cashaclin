import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/products_data.dart';

class CatalogPage extends StatefulWidget {
  final Function(Product, int) onAddToCart;
  const CatalogPage({super.key, required this.onAddToCart});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String searchTerm = '';
  String selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final categories = ['Todos', 'Lavandería', 'Pisos', 'Desinfección'];
    final products = mockProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchTerm.toLowerCase());
      final matchesCat = selectedCategory == 'Todos' || p.category == selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Catálogo de Productos",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
          ),
          const Text(
            "Precios especiales para minoristas y mayoristas",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Busca productos por nombre...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => searchTerm = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: selectedCategory == cat,
                  onSelected: (val) => setState(() => selectedCategory = cat),
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(
                    color: selectedCategory == cat ? Colors.white : Colors.black87,
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => _productCard(products[index]),
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _qtyBtn(Icons.remove, () => setStateCard(() => quantity = quantity > 1 ? quantity - 1 : 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text("$quantity"),
                          ),
                          _qtyBtn(Icons.add, () => setStateCard(() => quantity++)),
                        ],
                      ),
                      IconButton.filled(
                        onPressed: () => widget.onAddToCart(product, quantity),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                        ),
                      )
                    ],
                  )
                ],
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16),
    ),
  );
}
