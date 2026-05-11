import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductRepository _repository = ProductRepository();
  String searchTerm = '';
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _repository.getProducts();
    });
  }

  void _showProductDialog({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final skuController = TextEditingController(text: product?.sku ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '0.0',
    );
    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? "Nuevo Producto" : "Editar Producto"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: skuController,
                decoration: const InputDecoration(labelText: "SKU"),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Precio"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final p = Product(
                id:
                    product?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                sku: skuController.text,
                category: "General",
                image: product?.image ?? "https://via.placeholder.com/150",
                price: double.tryParse(priceController.text) ?? 0.0,
                stock: int.tryParse(stockController.text) ?? 0,
              );
              await _repository.addProduct(p);
              Navigator.pop(context);
              _refreshProducts();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Productos",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showProductDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text("Nuevo"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Text("No hay productos (Configura tu API REST)");

                final products = snapshot.data!
                    .where(
                      (p) => p.name.toLowerCase().contains(
                        searchTerm.toLowerCase(),
                      ),
                    )
                    .toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isMobile ? 180 : 250,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _card(products[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /* Widget _c1ard(Product p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Expanded(child: Image.network(p.image, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                Text("\$${p.price}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showProductDialog(product: p)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }//widget _card
*/
  Widget _card(Product product) {
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
                ),
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
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "\$${product.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.blue,
                          ),
                          onPressed: () => _showProductDialog(product: product),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
