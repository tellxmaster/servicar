import 'package:flutter/material.dart';

class TransactionToggle extends StatefulWidget {
  const TransactionToggle({super.key, required this.onSelected});
  final Function(int index) onSelected;

  @override
  // ignore: library_private_types_in_public_api
  _TransactionToggleState createState() => _TransactionToggleState();
}

class _TransactionToggleState extends State<TransactionToggle> {
  int _selectedIndex = -1; // -1 significa que no se ha seleccionado nada inicialmente

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: [0, 1].map((index) => index == _selectedIndex).toList(),
        onPressed: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onSelected(index);
        },
        borderRadius: BorderRadius.circular(20), // Bordes redondeados
        borderColor: Colors.grey.shade300, // Color del borde
        selectedBorderColor: Colors.deepPurple, // Color del borde al seleccionar
        borderWidth: 2,
        splashColor: Colors.deepPurpleAccent.shade100, // Color del efecto splash
        children: const <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.thumb_up, color: Colors.green, size: 20),
                  ),
                  Text('Sí'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.thumb_down, color: Colors.red, size: 20),
                  ),
                  Text('No'),
                ],
              ),
            ),
          ],
      ),
    );
  }
}