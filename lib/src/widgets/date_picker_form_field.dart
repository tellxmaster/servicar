import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Añade un nuevo parámetro al constructor de la clase para el callback
class DatePickerFormField extends StatefulWidget {
  final Function(DateTime)
      onDateSelected; // El callback que se invocará con la nueva fecha
  final DateTime initialDate; // Añadido para aceptar una fecha inicial
  const DatePickerFormField({super.key, required this.onDateSelected, required this.initialDate});

  @override
  State<DatePickerFormField> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  late TextEditingController _controller;
  late DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
     selectedDate = widget.initialDate; // Usar la fecha inicial del widget
    _controller = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.initialDate));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Aquí se invoca el callback pasando la fecha seleccionada
      widget.onDateSelected(picked);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Seleccionar Fecha',
        prefixIcon: Icon(Icons.date_range),
      ),
      validator: (value) =>
          value!.isEmpty ? 'Por favor seleccione una fecha' : null,
      onTap: () => _selectDate(context),
      readOnly: true,
    );
  }
}
