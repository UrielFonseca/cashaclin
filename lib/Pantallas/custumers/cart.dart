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
            Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Carrito vacío", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onGoToCatalog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Explorar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Mi Compra", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              IconButton(onPressed: onEmptyCart, icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 24)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.product.image, width: 45, height: 45, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 45)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("\$${item.product.price} x ${item.quantity}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _actionBtn(Icons.remove_circle_outline, () => onUpdateQuantity(index, -1)),
                            Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            _actionBtn(Icons.add_circle_outline, () => onUpdateQuantity(index, 1)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text("\$${item.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              children: [
                _miniRow("Subtotal", subtotal),
                _miniRow("IVA (16%)", iva),
                const Divider(height: 16),
                _miniRow("TOTAL", total, isTotal: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onGoToCatalog,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Color(0xFF1E3A8A))),
                        child: const Text("Seguir", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text("Pagar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _actionBtn(IconData icon, VoidCallback tap) => IconButton(icon: Icon(icon, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: tap);

  Widget _miniRow(String label, double val, {bool isTotal = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      Text("\$${val.toStringAsFixed(2)}", style: TextStyle(fontSize: isTotal ? 18 : 13, fontWeight: FontWeight.bold, color: isTotal ? Colors.green : Colors.black87)),
    ],
  );
}
