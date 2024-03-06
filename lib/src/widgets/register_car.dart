// Task: Formulario Registro de Carro por Usuario
import 'package:flutter/material.dart';
import 'package:servicar_movil/src/controllers/automovil_controller.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';

class RegisterCar extends StatefulWidget {
  static const String routeName = '/register_car';
  const RegisterCar({super.key});

  @override
  State<RegisterCar> createState() => _RegisterCarState();
}

class _RegisterCarState extends State<RegisterCar> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AutomovilController _automovilController = AutomovilController();
  late String _placa;
  late int _kilometraje;
  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _automovilController
          .agregarAutomovil(_placa, _kilometraje)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carro Registrado Correctamente'),
            backgroundColor: Color(0xFF28A745),
          ),
        );

        Navigator.of(context).pushNamed(DashboardScreen.routeName);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocurrió un error'),
            backgroundColor: Color(0xFFdc3545),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFFFFFFF), // Blanco puro, color de inicio
                  Color(
                      0xFFF7F7F7), // Gris muy claro, casi blanco, color de fin
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Registrar Vehiculo',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 50),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            _crearPlaca(),
                            const SizedBox(height: 20),
                            _crearKilometrajeActual(),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 20.0),
                                ),
                                onPressed: _registrar,
                                child: const Text('REGISTRAR'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  Widget _crearPlaca() {
    return TextFormField(
      decoration: const InputDecoration(
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        labelText: ('Placa del Vehiculo'),
        prefixIcon: Icon(Icons.person),
      ),
      onSaved: (value) => _placa = value!,
      validator: (value) =>
          value!.isEmpty ? 'Por favor ingrese su placa' : null,
    );
  }

  Widget _crearKilometrajeActual() {
    return TextFormField(
      decoration: const InputDecoration(
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        labelText: ('Kilometraje actual'),
        prefixIcon: Icon(Icons.drive_eta),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) => _kilometraje = int.parse(value!),
      validator: (value) =>
          value!.isEmpty ? 'Por favor ingrese el kilometraje' : null,
    );
  }
}
