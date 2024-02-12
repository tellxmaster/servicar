import 'package:flutter/material.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
import 'package:servicar_movil/src/widgets/home_screen.dart';
import 'package:servicar_movil/src/widgets/register_appointment.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UsuarioController _usuarioController = UsuarioController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            // Add your calendar logic here
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _usuarioController.cerrarSesion(context).then((_) {
                Navigator.of(context)
                    .pushReplacementNamed(HomeScreen.routeName);
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ocurrió un error'),
                    backgroundColor: Color(0xFFdc3545),
                  ),
                );
              });
            },
          )
        ],
        backgroundColor: Colors.deepPurple, // Improved AppBar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _vehicleDataCard(),
              const SizedBox(height: 20),
              _technicalDataSection(),
              const SizedBox(height: 20),
              _appointmentSummarySection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RegisterAppointment.routeName);
        },
        child: const Icon(Icons.add),
        backgroundColor:
            Colors.deepPurple, // Match the FloatingActionButton with AppBar
      ),
    );
  }

  Widget _vehicleDataCard() => Card(
        color: const Color(0xFF4709C), // Adjusted color value
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Datos del vehiculo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              _vehicleDataRow(),
            ],
          ),
        ),
      );

  Widget _vehicleDataRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _vehicleDetailColumn(
            title: 'Kilometraje',
            value: '20000 km', // Replace with actual data
          ),
          _vehicleDetailColumn(
            title: 'Placa',
            value: 'TBD2415', // Replace with actual data
          ),
          const Text('Tipo: Auto'), // Replace with actual data
        ],
      );

  Widget _vehicleDetailColumn({required String title, required String value}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      );

  Widget _technicalDataSection() => const Text(
        'Datos tecnicos del auto',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );

  Widget _appointmentSummarySection() => const Text(
        'Resumen de citas',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
}
