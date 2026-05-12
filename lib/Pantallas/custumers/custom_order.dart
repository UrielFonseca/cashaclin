import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../repositories/sale_repository.dart';

/*
  Pantalla de Pedido Especial:
  Permite a los usuarios finales realizar solicitudes de productos personalizados o compras por volumen.
  Incluye una validación de formulario y un calendario interactivo para la selección de la fecha de entrega.
*/
class CustomOrderPage extends StatefulWidget {
  const CustomOrderPage({super.key});

  @override
  State<CustomOrderPage> createState() => _CustomOrderPageState();
}

class _CustomOrderPageState extends State<CustomOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final commentCtrl = TextEditingController();
  final SaleRepository _repository = SaleRepository();
  bool _isLoading = false;
  
  // Variables para la gestión del estado del calendario
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Se inicializa el día seleccionado con el día actual por defecto
    _selectedDay = _focusedDay;
  }

  /*
    Función para enviar la solicitud al servidor:
    1. Valida el formulario.
    2. Crea un objeto de venta de tipo 'especial'.
    3. Asocia la fecha seleccionada en el calendario.
  */
  void _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verifica que se haya seleccionado un día
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Por favor selecciona una fecha en el calendario")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Envío de datos al repositorio (Backend MongoDB)
      await _repository.createSale({
        'customerName': nameCtrl.text,
        'comment': commentCtrl.text,
        'total': 0.0, // El precio será asignado por el administrador posteriormente
        'type': 'especial',
        'status': 'Esperando aprobación',
        'date': _selectedDay!.toIso8601String(),
        'items': [], // Los pedidos especiales no tienen ítems definidos inicialmente
        'messages': [
          {'sender': 'customer', 'text': 'Solicitud inicial: ${commentCtrl.text}'}
        ]
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Exito: Solicitud enviada correctamente")));
        // Limpieza de campos tras el éxito
        nameCtrl.clear();
        commentCtrl.clear();
        setState(() {
          _selectedDay = DateTime.now();
          _focusedDay = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: No se pudo enviar la solicitud")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pedido Especial",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A))),
            const Text("Pide mayoreo o productos personalizados", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre Completo", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)
                ),
                validator: (v) => v!.isEmpty ? "Campo requerido" : null),
            
            const SizedBox(height: 24),
            const Text("Fecha Tentativa de Entrega", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            
            // Integración de TableCalendar para una experiencia de selección de fecha profesional
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2026, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            TextFormField(
                controller: commentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: "Detalles del pedido",
                    hintText: "Ej: 50 litros de detergente...",
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Cuéntanos qué necesitas" : null),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), 
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("ENVIAR SOLICITUD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
