import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _finalizeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator())
    );

    try {
      final batch = FirebaseFirestore.instance.batch();
      final saleId = FirebaseFirestore.instance.collection('sales').doc().id;
      // Corregido: Usamos 0.0 para que sea double
      double subtotal = widget.cart.fold(0.0, (sum, item) => sum + item.total);

      batch.set(FirebaseFirestore.instance.collection('sales').doc(saleId), {
        'customerName': nameCtrl.text,
        'customerEmail': emailCtrl.text,
        'total': subtotal * 1.16,
        'status': 'Completada',
        'date': FieldValue.serverTimestamp(),
        'items': widget.cart.map((i) => {'name': i.product.name, 'qty': i.quantity}).toList(),
      });

      batch.set(FirebaseFirestore.instance.collection('customers').doc(emailCtrl.text), {
        'name': nameCtrl.text,
        'email': emailCtrl.text,
        'phone': 'Sin registrar',
        'lastPurchase': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      for (var item in widget.cart) {
        batch.update(FirebaseFirestore.instance.collection('products').doc(item.product.id), {
          'stock': FieldValue.increment(-item.quantity)
        });
      }

      await batch.commit();
      
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Cerrar Loading
        Navigator.pop(context); // Cerrar Dialogo Formulario
        widget.onEmptyCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Pedido Confirmado"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Error de conexión")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Corregido: Usamos 0.0 aquí también
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline, size: 18), onPressed: () => widget.onUpdateQuantity(index, -1)),
                    Text("${item.quantity}"),
                    IconButton(icon: const Icon(Icons.add_circle_outline, size: 18), onPressed: () => widget.onUpdateQuantity(index, 1)),
                    const SizedBox(width: 10),
                    Text("\$${item.total.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
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
