import 'package:flutter/material.dart';
import 'package:servicar_movil/src/widgets/register_appointment.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(
              color: const Color(0x0ff4709c),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Datos del vehiculo',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kilometraje',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '20000 km', // TODO: Añade el año del vehículo
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Placa',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  'TBD2415', // TODO: Añade la placa del vehículo
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                                'Tipo: Auto'), // TODO: Añade el tipo de vehículo
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(RegisterAppointment.routeName);
                },
                child: Text('Agendar Nueva Cita'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Datos tecnicos del auto',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            // Solo muestra la sección de Alertas si hay alertas
            const SizedBox(height: 20),
            const Text(
              'Resumen de citas',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }
}
