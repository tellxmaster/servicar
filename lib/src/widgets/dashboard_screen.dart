import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicar_movil/src/controllers/automovil_controller.dart';
import 'package:servicar_movil/src/controllers/cita_controller.dart';
import 'package:servicar_movil/src/controllers/servicio_controller.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
import 'package:servicar_movil/src/models/automovil.dart';
import 'package:servicar_movil/src/models/cita.dart';
import 'package:servicar_movil/src/widgets/home_screen.dart';
import 'package:servicar_movil/src/widgets/register_appointment.dart';
import 'package:intl/intl.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UsuarioController _usuarioController = UsuarioController();
  Future<void>? _loadUserDataFuture;
  Automovil? _automovil;
  List<Cita>? _citas;
  Map<String, String> _serviceNames = {};
  
  @override
  void initState() {
    super.initState();
    _loadUserDataFuture= loadUserData();
  }
  String formatTimestamp(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  // Formatea la fecha como prefieras. Ejemplo: 20 de enero de 2024, 5:00 PM
  String formattedDate = DateFormat('d MMMM yyyy, h:mm a', 'es_ES').format(date);

  return formattedDate;
  }
  Future<void> loadUserData() async {
    UsuarioController usuarioController =
        Provider.of<UsuarioController>(context, listen: false);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await usuarioController.loadUser(uid);
    try {
      Automovil auto =
          await Provider.of<AutomovilController>(context, listen: false)
              .obtenerAutoDataPorUid(uid);
       List<Cita> citas = // Cambiado para recibir una lista de citas
        await Provider.of<CitasController>(context, listen: false)
            .obtenerCitasPorUsuario(uid);
        for (var cita in citas) {
          loadServiceName(cita.idServicio);
        }
      setState(() {
        _automovil = auto;
        _citas = citas;
      });
    } catch (e) {
      print("Error al obtener el automóvil: $e");
    }
  }
  Future<void> loadServiceName(String idServicio) async {
    try {
        print('Cargando servicio para id: $idServicio'); // Depuración
        String nombre = await Provider.of<ServicioController>(context, listen: false)
            .obtenerServicioPoridServicio(idServicio);
        setState(() {
          _serviceNames[idServicio] = nombre;
        });
        print('Servicio cargado: $nombre'); // Depuración
      } catch (e) {
        print('Error al cargar el nombre del servicio: $e'); // Depuración
      }
    }
  
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: _loadUserDataFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // Muestra un indicador de carga mientras se espera
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
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
              backgroundColor:
                  const Color.fromARGB(255, 22, 22, 22), // Improved AppBar color
            ),
            body: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(minHeight: screenHeight),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF673AB7), // Start color
                      Color.fromRGBO(124, 77, 255, 1), // End color
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _vehicleDataCard(),
                        const SizedBox(height: 20),
                        _quotesTitle(),
                        const SizedBox(height: 20),
                        _quotesDataCard(),
                        const SizedBox(height: 20),
                        _technicalDataSection(),
                        
                      ],
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(RegisterAppointment.routeName);
              },
              foregroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
            ),
          );
        }
      }
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
Widget _quotesDataCard() {
  return SingleChildScrollView(
    child: Column(
      children: [
        _citas != null && _citas!.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true, // para evitar el error "Vertical viewport was given unbounded height"
                physics: NeverScrollableScrollPhysics(), // para evitar que el ListView.builder intente desplazarse
                itemCount: _citas!.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF4709C), // Ajusta el valor del color si es necesario
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _quotesDataRow(_citas![index]),
                    ),
                  );
                },
              )
            : const Card(
                color: Color(0xFF4709C), // Ajusta el valor del color si es necesario
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No hay citas disponibles."),
                ),
              ),
      ],
    ),
  );
}

Widget _quotesDataRow(Cita cita){ 
  String serviceName = _serviceNames[cita.idServicio] ?? 'Cargando...';
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _quoteDetailColumn(
            title: 'Servicio',
            value: serviceName, // Replace with actual data
          ),
          _quoteDetailColumn(
            title: 'Estado',
            value: cita.estado, // Replace with actual data
          ),
           _quoteDetailColumn(
            title: 'Fecha y Hora de Inicio',
            value:formatTimestamp(cita.fechaHoraInicio), // Replace with actual data
           ),
            _quoteDetailColumn(
            title: 'Fecha y Hora de Finalización',
            value:formatTimestamp(cita.fechaHoraFin), // Replace with actual data
           ),
          // _vehicleDetailColumn(
          //   title: 'Fecha y Hora de Finalización',
          //   value: cita.fechaHoraFin.toString(), // Replace with actual data
          // ),
          // _vehicleDetailColumn(
          //   title: 'Trabajador',
          //   value: cita.idTrabajador, // Replace with actual data
          // ),
          // const Text('Tipo: Cita'), // Replace with actual data
        ],
      );
    }
  Widget _vehicleDataRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _vehicleDetailColumn(
            title: 'Kilometraje',
            value: _automovil?.kilometrajeActual.toString() ?? '-', // Replace with actual data
          ),
          _vehicleDetailColumn(
            title: 'Placa',
            value: _automovil?.placa ?? '-', // Replace with actual data
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
  Widget _quoteDetailColumn({required String title, required String value}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 22, 22, 22)),
            ),
          ),
          Center(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 7),
        ],
      );
  Widget _technicalDataSection() => const Text(
        'Datos tecnicos del auto',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );

  Widget _quotesTitle() => const Text(
        'Resumen de citas',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
  
}
