import 'package:flutter/material.dart';
import '../models/cart_model.dart';

class CartPage extends StatelessWidget {
  final List<CartItem> cart;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onEmptyCart;
  final VoidCallback onGoToCatalog;

  const CartPage({
    super.key,
    required this.cart,
    required this.onUpdateQuantity,
    required this.onEmptyCart,
    required this.onGoToCatalog,
  });

  @override
  Widget build(BuildContext context) {
    double subtotal = cart.fold(0, (sum, item) => sum + item.total);
    double iva = subtotal * 0.16;
    double total = subtotal + iva;

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Tu carrito está vacío", style: TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onGoToCatalog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Explorar Catálogo", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mi Carrito",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              TextButton.icon(
                onPressed: onEmptyCart,
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text("Vaciar Carrito", style: TextStyle(color: Colors.red)),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("\$${item.product.price} x ${item.quantity}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => onUpdateQuantity(index, -1)),
                        Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onUpdateQuantity(index, 1)),
                        const SizedBox(width: 20),
                        Text("\$${item.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _priceRow("Subtotal", subtotal),
                _priceRow("IVA (16%)", iva),
                const Divider(height: 32),
                _priceRow("TOTAL", total, isTotal: true),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onGoToCatalog,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text("Continuar Comprando"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Finalizar Compra",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _priceRow(String label, double val, {bool isTotal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 20 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(
          "\$${val.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: isTotal ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.green : Colors.black87,
          ),
        ),
      ],
    ),
  );
}
