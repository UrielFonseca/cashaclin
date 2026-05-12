import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../repositories/sale_repository.dart';

/*
  Pantalla de Pedido Especial:
  Permite a los usuarios realizar solicitudes de productos personalizados o compras por volumen.
  Incluye validación de formulario y un calendario interactivo para definir la fecha de entrega.
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
  
  // Variables para la gestión del calendario interactivo.
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Inicialización del día seleccionado con la fecha actual.
    _selectedDay = _focusedDay;
  }

  /*
    Lógica de envío de solicitud:
    1. Valida los campos obligatorios del formulario.
    2. Asegura la selección de una fecha válida.
    3. Registra el pedido en el servidor como tipo 'especial'.
  */
  void _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Seleccione una fecha en el calendario")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Sincronización con el servidor mediante el repositorio de ventas.
      await _repository.createSale({
        'customerName': nameCtrl.text,
        'comment': commentCtrl.text,
        'total': 0.0, // El monto final será asignado por el administrador.
        'type': 'especial',
        'status': 'Esperando aprobación',
        'date': _selectedDay!.toIso8601String(),
        'items': [],
        'messages': [
          {'sender': 'customer', 'text': 'Solicitud inicial: ${commentCtrl.text}'}
        ]
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Éxito: Solicitud enviada correctamente")));
        
        // Reinicio de los controladores tras el envío exitoso.
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
            const SnackBar(content: Text("Error: No se pudo procesar la solicitud")));
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
            const Text("Solicite productos por volumen o artículos personalizados", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            // Entrada de datos para el nombre del solicitante.
            TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre Completo", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)
                ),
                validator: (v) => v!.isEmpty ? "Este campo es requerido" : null),
            
            const SizedBox(height: 24),
            const Text("Fecha Tentativa de Entrega", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            
            // Componente de calendario para selección de fecha operativa.
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
            // Área de texto para detalles de la solicitud.
            TextFormField(
                controller: commentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: "Detalles del pedido",
                    hintText: "Especifique artículos, cantidades y requerimientos...",
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Por favor proporcione detalles" : null),
            
            const SizedBox(height: 30),
            // Botón de procesamiento de solicitud.
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
                    : const Text("PROCESAR SOLICITUD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
