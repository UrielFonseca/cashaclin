import 'package:flutter/material.dart';
import '../../repositories/product_repository.dart';
import '../models/product_model.dart';

/*
  Pantalla de Catálogo de Productos:
  Interfaz principal donde el cliente puede visualizar, buscar y filtrar artículos.
  Permite añadir productos al carrito de compras con control de cantidades.
*/
class CatalogPage extends StatefulWidget {
  final Function(Product, int) onAddToCart;
  const CatalogPage({super.key, required this.onAddToCart});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ProductRepository _repository = ProductRepository();
  String searchTerm = ''; // Término de búsqueda para filtrar por nombre.
  String selectedCategory = 'Todos'; // Categoría seleccionada para el filtrado.
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Inicializa la carga de productos desde la API.
    _refreshProducts();
  }

  /// Recarga la lista de productos consultando al repositorio central.
  void _refreshProducts() {
    setState(() {
      _productsFuture = _repository.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listado de categorías disponibles en el sistema.
    final categories = ['Todos', 'Limpieza', 'Lavado', 'Desinfección'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Catálogo de Productos", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const Text("Precios especiales minoristas/mayoristas", 
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          
          // Barra de búsqueda con actualización reactiva.
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar producto por nombre...",
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
                borderSide: BorderSide.none
              ),
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
          const SizedBox(height: 12),
          
          // Selector de categorías mediante ChoiceChips.
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
                  labelStyle: TextStyle(
                    color: selectedCategory == cat ? Colors.white : Colors.black87
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de productos renderizada dinámicamente mediante FutureBuilder.
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) 
                  return const Center(child: CircularProgressIndicator());
                
                if (snapshot.hasError) 
                  return const Center(child: Text("Error: No se pudo conectar con el catálogo de productos"));
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) 
                  return const Center(child: Text("No hay productos disponibles actualmente"));

                // Filtrado local de la lista obtenida del servidor.
                final products = snapshot.data!.where((p) {
                  final matchesSearch = p.name.toLowerCase().contains(searchTerm.toLowerCase());
                  final matchesCat = selectedCategory == 'Todos' || p.category == selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                if (products.isEmpty) 
                  return const Center(child: Text("No se encontraron resultados para los filtros aplicados"));

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _productCard(products[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la tarjeta individual para cada producto del catálogo.
  Widget _productCard(Product product) {
    int quantity = 1; // Cantidad seleccionada por defecto.
    return StatefulBuilder(
      builder: (context, setStateCard) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Representación visual del producto.
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.image, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                ),
              ),
            ),
            // Información y controles de compra.
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
                        Text(product.category.toUpperCase(), 
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text(product.name, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis),
                        Text("\$${product.price.toStringAsFixed(0)}", 
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Controles para ajustar la cantidad antes de añadir al carrito.
                        Row(
                          children: [
                            _qtyBtn(Icons.remove, () => setStateCard(() => quantity = quantity > 1 ? quantity - 1 : 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4), 
                              child: Text("$quantity", style: const TextStyle(fontSize: 12))
                            ),
                            _qtyBtn(Icons.add, () => setStateCard(() => quantity++)),
                          ],
                        ),
                        // Botón de acción para agregar el pedido.
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

  /// Botón circular pequeño para el control de cantidades.
  Widget _qtyBtn(IconData icon, VoidCallback tap) => InkWell(
    onTap: tap,
    child: Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), 
        borderRadius: BorderRadius.circular(6)
      ),
      child: Icon(icon, size: 14),
    ),
  );
}
