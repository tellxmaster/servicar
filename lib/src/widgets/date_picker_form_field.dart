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
      decoration: const InputDecoration(
        labelText: 'Fecha',
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true, // Hace el campo de texto de solo lectura
      onTap: () async {
        DateTime now = DateTime.now();
        DateTime firstDate = now;
        DateTime lastDate = now.add(const Duration(days: 7));

        // Ajustar lastDate para que sea viernes si es necesario
        while (lastDate.weekday > 5) {
          lastDate = lastDate.subtract(const Duration(days: 1));
        }

        // Mostrar el selector de fecha
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDate,
          lastDate: lastDate,
          selectableDayPredicate: (DateTime day) {
            // Permite seleccionar solo días de semana (Lunes a Viernes)
            return day.weekday < 6;
          },
        );

        if (pickedDate != null) {
          // Si se selecciona una fecha, actualiza el valor del controlador y notifica al widget padre
          widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          widget.onDateSelected(pickedDate);
        }
      },
    );
  }
}
