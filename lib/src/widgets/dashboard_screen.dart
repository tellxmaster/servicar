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
import 'package:servicar_movil/src/widgets/info_cita.dart';
import 'package:servicar_movil/src/widgets/register_appointment.dart';
import 'package:intl/intl.dart';
import 'package:servicar_movil/src/widgets/taller_map_page.dart';

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
  final Map<String, String> _serviceNames = {};

  @override
  void initState() {
    super.initState();
    _loadUserDataFuture = loadUserData();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    // Formatea la fecha como prefieras. Ejemplo: 20 de enero de 2024, 5:00 PM
    String formattedDate = DateFormat('h:mm a', 'es_ES').format(date);

    return formattedDate;
  }

  String getDayTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    // Formatea el día. Ejemplo: 20
    return DateFormat('dd', 'es_ES').format(date);
  }

  String getMonthTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    // Formatea el mes como nombre. Ejemplo: enero
    return DateFormat('MMM', 'es_ES')
        .format(date); // MMM para abreviatura del mes
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
      String nombre =
          await Provider.of<ServicioController>(context, listen: false)
              .obtenerServicioPoridServicio(idServicio);
      setState(() {
        _serviceNames[idServicio] = nombre;
      });
      print('Servicio cargado: $nombre'); // Depuración
    } catch (e) {
      print('Error al cargar el nombre del servicio: $e'); // Depuración
    }
  }

  void _goToInfoCita(String cita) async {
    bool updated = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => InfoCita(id: cita)));

    if (updated) {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      final citas = CitasController().obtenerCitasPorUsuario(uid);

      citas.then((citasActualizadas) {
        setState(() {
          _citas = citasActualizadas;

          // Recargar nombres de servicios
          for (var cita in _citas!) {
            loadServiceName(cita.idServicio);
          }
        });
      });
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
                title: const Text('ServiCar'),
                centerTitle: true,
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Image.asset('assets/logo.png'),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    );
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
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      decoration: const BoxDecoration(color: Color(0xFF673AB7)),
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/logo.png', // Tu logo aquí
                              width: 80.0,
                              height: 80.0,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize
                                  .min, // Esto hace que la Columna ocupe solo el espacio necesario.
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bienvenido', // Accede directamente al email del usuario
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${FirebaseAuth.instance.currentUser?.email}', // Accede directamente al email del usuario
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 217, 255),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on_rounded),
                      title: const Text('Ubicaciòn del taller'),
                      onTap: () {
                        // Navega a TallerMapPage cuando el tile es tocado
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TallerMapPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Cerrar Sesiòn"),
                      onTap: () {
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
              ),
              body: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: screenHeight),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _vehicleDataCard(),
                          const SizedBox(height: 20),
                          _quotesTitle(),
                          const SizedBox(height: 20),
                          _quotesDataCard(context),
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
                  Navigator.of(context)
                      .pushNamed(RegisterAppointment.routeName);
                },
                child: const Icon(Icons.add),
              ),
            );
          }
        });
  }

  Widget _vehicleDataCard() => Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        elevation: 5,
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
              Image.asset('assets/car_icon.png'),
              const SizedBox(height: 10),
              _vehicleDataRow(),
            ],
          ),
        ),
      );
  Widget _quotesDataCard(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _citas != null && _citas!.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _citas!.length,
                  itemBuilder: (context, index) {
                    final cita = _citas![index];
                    return InkWell(
                      onTap: () {
                        // Navega a InfoCita enviando el id de la cita
                        _goToInfoCita(cita.idCita);
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          child: _quotesDataRow(cita),
                        ),
                      ),
                    );
                  },
                )
              : const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No hay citas disponibles."),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _quotesDataRow(Cita cita) {
    String serviceName = _serviceNames[cita.idServicio] ?? 'Cargando...';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getDayTimestamp(cita.fechaHoraInicio), // Ejemplo: "03"
                  style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF673AB7)),
                ),
                Text(
                  getMonthTimestamp(cita.fechaHoraInicio)
                      .toString()
                      .toUpperCase(), // Ejemplo: "MAR"
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF673AB7)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _quoteDetailRow(
                title: 'Servicio',
                value: serviceName, // Reemplaza con los datos reales
              ),
              _quoteDetailRow(
                title: 'Estado',
                value: cita.estado, // Reemplaza con los datos reales
              ),
              _quoteDetailRow(
                title: 'Inicio',
                value: formatTimestamp(
                    cita.fechaHoraInicio), // Reemplaza con los datos reales
              ),
              _quoteDetailRow(
                title: 'Finalización',
                value: formatTimestamp(
                    cita.fechaHoraFin), // Reemplaza con los datos reales
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _vehicleDataRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _vehicleDetailColumn(
            title: 'Kilometraje',
            value: _automovil?.kilometrajeActual.toString() ??
                '-', // Replace with actual data
          ),
          _vehicleDetailColumn(
            title: 'Placa',
            value: _automovil?.placa ?? '-', // Replace with actual data
          ),
          _vehicleDetailColumn(
            title: 'Tipo',
            value: 'Auto', // Replace with actual data
          ),
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
              style: const TextStyle(
                  fontSize: 13, color: Color.fromARGB(255, 22, 22, 22)),
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

  Widget _quoteDetailRow({required String title, required String value}) => Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Alinea los hijos al inicio del Row
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold, // Hace el título en negritas
              color: Color.fromARGB(255, 22, 22, 22),
            ),
            textAlign: TextAlign
                .right, // Aunque el texto está a la derecha, esto no afectará sin espacio adicional
          ),
          const SizedBox(width: 8), // Espacio entre el título y el valor
          Text(
            value,
            style: const TextStyle(
              fontSize: 13, // Asegura consistencia en el tamaño de la fuente
              color: Color.fromARGB(
                  255, 22, 22, 22), // Ajusta el color según sea necesario
            ),
            textAlign: TextAlign.left, // Alinea el texto a la izquierda
          ),
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
