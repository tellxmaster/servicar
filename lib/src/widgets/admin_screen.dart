import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servicar_movil/src/controllers/cita_controller.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
import 'package:servicar_movil/src/widgets/home_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);
  static const String routeName = '/admin';

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final CitasController _citasController = CitasController();
  Future<List<Map<String, dynamic>>>? _citasDetailsFuture;
  final UsuarioController _usuarioController = UsuarioController();

  @override
  void initState() {
    super.initState();
    _citasDetailsFuture = _citasController.getAllCitasDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ServiCar - Admin'),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/logo.png'),
          onPressed: () {},
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
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _citasDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar las citas: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> citasDetails = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Próximas citas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: citasDetails.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> citaDetail = citasDetails[index];
                      String formattedDate =
                          DateFormat('dd/MM/yyyy h:mm a').format(
                        (citaDetail['fechaHoraInicio'] as Timestamp).toDate(),
                      );

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_month_sharp),
                          title: Text(
                            citaDetail['nombreServicio'] ??
                                'Servicio desconocido',
                          ),
                          subtitle: Text(
                            '${citaDetail['nombreCliente'] ?? 'Cliente desconocido'} - $formattedDate',
                          ),
                          trailing: Text(
                            citaDetail['nombreTrabajador'] ??
                                'Trabajador desconocido',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No hay citas disponibles'));
          }
        },
      ),
    );
  }
}
