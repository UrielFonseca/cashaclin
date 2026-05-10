import 'package:flutter/material.dart';
import '../../repositories/sale_repository.dart';
import '../../repositories/product_repository.dart';
import '../models/cart_model.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cart;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onEmptyCart;
  final VoidCallback onGoToCatalog;

  const CartPage({super.key, required this.cart, required this.onUpdateQuantity, required this.onEmptyCart, required this.onGoToCatalog});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final SaleRepository _saleRepo = SaleRepository();
  final ProductRepository _productRepo = ProductRepository();

  Future<void> _finalizeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      double subtotal = widget.cart.fold(0.0, (sum, item) => sum + item.total);

      // Enviar pedido a la API
      await _saleRepo.createSale({
        'customerName': nameCtrl.text,
        'customerEmail': emailCtrl.text,
        'total': subtotal * 1.16,
        'status': 'Completada',
        'items': widget.cart.map((i) => {'productId': i.product.id, 'qty': i.quantity}).toList(),
      });

      // Actualizar stock localmente (la API también debería hacerlo en el back)
      for (var item in widget.cart) {
        await _productRepo.updateStock(item.product.id, item.product.stock - item.quantity);
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Cerrar Loading
        Navigator.pop(context); // Cerrar Formulario
        widget.onEmptyCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Pedido Sincronizado vía API"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Error al conectar con el servidor")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.cart.fold(0.0, (sum, item) => sum + item.total) * 1.16;

    if (widget.cart.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.shopping_basket_outlined, size: 70, color: Colors.grey),
        const SizedBox(height: 10),
        const Text("Carrito Vacío"),
        TextButton(onPressed: widget.onGoToCatalog, child: const Text("Ir a comprar"))
      ]));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Mi Compra", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(onPressed: widget.onEmptyCart, icon: const Icon(Icons.delete_sweep, color: Colors.red))
          ]),
          Expanded(child: ListView.builder(
            itemCount: widget.cart.length,
            itemBuilder: (context, index) {
              final item = widget.cart[index];
              return ListTile(
                leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.product.image, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))),
                title: Text(item.product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1),
                subtitle: Text("${item.quantity} x \$${item.product.price}"),
                trailing: Text("\$${item.total.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }
          )),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("TOTAL (IVA inc.)"), Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green))]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () => _showForm(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                child: const Text("PAGAR AHORA", style: TextStyle(color: Colors.white)),
              ))
            ]),
          )
        ],
      ),
    );
  }

  void _showForm() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Datos de Entrega"),
      content: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre"), validator: (v)=>v!.isEmpty?"Requerido":null),
        TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email"), validator: (v)=>v!.isEmpty?"Requerido":null),
      ]))),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(onPressed: _finalizeOrder, child: const Text("Confirmar"))
      ],
    ));
  }
}
