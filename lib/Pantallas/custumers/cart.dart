import 'package:flutter/material.dart';
import '../../repositories/sale_repository.dart';
import '../../repositories/product_repository.dart';
import '../../services/sqlite_service.dart';
import '../models/cart_model.dart';

/*
  Pantalla del Carrito de Compras:
  Gestiona el resumen de los productos seleccionados, el cálculo de totales con IVA
  y el proceso de finalización de compra integrando servicios de API y persistencia local (SQLite).
*/
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
  final SqliteService _sqliteService = SqliteService();

  /*
    Lógica de finalización de pedido:
    1. Registra la transacción en la base de datos central (MongoDB).
    2. Almacena una copia del recibo en la base de datos local (SQLite).
    3. Actualiza los niveles de stock en el servidor.
  */
  Future<void> _finalizeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Despliegue de indicador de progreso durante la comunicación con el servidor.
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      double subtotal = widget.cart.fold(0.0, (sum, item) => sum + item.total);
      double totalWithIva = subtotal * 1.16;

      // Sincronización con el Backend mediante API REST.
      await _saleRepo.createSale({
        'customerName': nameCtrl.text,
        'customerEmail': emailCtrl.text,
        'total': totalWithIva,
        'status': 'Completada',
        'type': 'carrito',
        'items': widget.cart.map((i) => {'productId': i.product.id, 'name': i.product.name, 'qty': i.quantity}).toList(),
      });

      // Registro en la persistencia local del dispositivo.
      await _sqliteService.saveOrderLocal(
        "REC-${DateTime.now().millisecondsSinceEpoch}", 
        nameCtrl.text, 
        totalWithIva
      );

      // Actualización masiva de inventario.
      for (var item in widget.cart) {
        await _productRepo.updateStock(item.product.id, item.product.stock - item.quantity);
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Cierre del loading.
        Navigator.pop(context); // Cierre del formulario de confirmación.
        widget.onEmptyCart(); // Limpieza del estado local del carrito.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pedido confirmado exitosamente. Copia guardada en SQLite local."),
            backgroundColor: Colors.green, 
            behavior: SnackBarBehavior.floating
          )
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No se pudo procesar la transacción")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.cart.fold(0.0, (sum, item) => sum + item.total) * 1.16;

    if (widget.cart.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.shopping_basket_outlined, size: 70, color: Colors.grey),
        const Text("Su carrito se encuentra vacío", style: TextStyle(color: Colors.grey)),
        TextButton(onPressed: widget.onGoToCatalog, child: const Text("Explorar catálogo"))
      ]));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Resumen de Compra", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(onPressed: widget.onEmptyCart, icon: const Icon(Icons.delete_sweep, color: Colors.red))
          ]),
          Expanded(child: ListView.builder(
            itemCount: widget.cart.length,
            itemBuilder: (context, index) {
              final item = widget.cart[index];
              return ListTile(
                leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.product.image, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))),
                title: Text(item.product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1),
                subtitle: Text("${item.quantity} unidades x \$${item.product.price}"),
                trailing: Text("\$${item.total.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }
          )),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Final (IVA incluido)"), Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green))]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () => _showForm(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                child: const Text("PROCEDER AL PAGO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ))
            ]),
          )
        ],
      ),
    );
  }

  /// Despliega el formulario de validación de identidad para el pago.
  void _showForm() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Información de Facturación"),
      content: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre Completo"), validator: (v)=>v!.isEmpty?"Este campo es requerido":null),
        TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email de contacto"), validator: (v)=>v!.isEmpty?"Este campo es requerido":null),
      ]))),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(onPressed: _finalizeOrder, child: const Text("Confirmar Transacción"))
      ],
    ));
  }
}
