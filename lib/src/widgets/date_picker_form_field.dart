import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerFormField extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final TextEditingController controller;

  const DatePickerFormField({
    super.key,
    required this.onDateSelected,
    required this.controller,
  });

  @override
  State<DatePickerFormField> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Fecha',
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true, // Hace el campo de texto de solo lectura
      onTap: () async {
        // Mostrar el selector de fecha
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          // Si se selecciona una fecha, actualiza el valor del controlador y notifica al widget padre
          print(pickedDate);
          widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          widget.onDateSelected(pickedDate);
        }
      },
    );
  }
}
