import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickeFormField extends StatefulWidget {
  const DatePickeFormField({super.key});

  @override
  State<DatePickeFormField> createState() => _DatePickeFormFieldState();
}

class _DatePickeFormFieldState extends State<DatePickeFormField> {
  late TextEditingController _controller;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Fecha inicial seleccionada
      firstDate: DateTime.now(), // La fecha actual como primer fecha disponible
      lastDate: DateTime.now().add(const Duration(
          days: 7)), // Máximo una semana a partir de la fecha actual
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Formatea la fecha y la asigna al controlador del campo de texto para mostrarla
        _controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
      onTap: () => _selectDate(context), // Abre el DatePicker al tocar el campo
      readOnly: true, // Hace el campo de texto no editable directamente
    );
  }
}
