import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/products_data.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
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

  void _showProductDialog({Product? product}) {
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
        title: Text(product == null ? "Nuevo Producto" : "Editar Producto"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Nombre"),
              _buildTextField(skuController, "SKU / Clave"),
              _buildTextField(categoryController, "Categoría"),
              _buildTextField(descController, "Descripción", maxLines: 3),
              _buildTextField(priceController, "Precio", keyboardType: TextInputType.number),
              _buildTextField(stockController, "Stock Inicial", keyboardType: TextInputType.number),
              _buildTextField(imageController, "URL de Imagen"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final newProduct = Product(
                id: product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                sku: skuController.text,
                category: categoryController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                stock: int.tryParse(stockController.text) ?? 0,
                image: imageController.text,
              );

              setState(() {
                if (product == null) {
                  products.add(newProduct);
                } else {
                  final index = products.indexWhere((p) => p.id == product.id);
                  products[index] = newProduct;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Productos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text("Administra tus artículos", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showProductDialog(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Nuevo Producto"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Catálogo de Productos", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text("Administra la información pública de tus artículos"),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showProductDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text("Nuevo Producto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  )
                ],
              ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: "Buscar por nombre o clave...",
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (value) => setState(() => searchTerm = value),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: isMobile ? 200 : 300,
              childAspectRatio: isMobile ? 0.6 : 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) => _productCard(filteredProducts[index], isMobile),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product product, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(child: Icon(Icons.image_not_supported, size: 30, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                    child: Text(product.sku, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Text("\$${product.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Text(product.category, style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (!isMobile)
                    Expanded(
                      child: Text(product.description, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("S: ${product.stock}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: product.stock <= 10 ? Colors.red : Colors.black87)),
                      Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                            onPressed: () => _showProductDialog(product: product),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            onPressed: () {
                              setState(() => products.removeWhere((p) => p.id == product.id));
                            },
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
