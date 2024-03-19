import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servicar_movil/src/controllers/cita_controller.dart';
import 'package:servicar_movil/src/controllers/servicio_controller.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
import 'package:servicar_movil/src/models/cita.dart';
import 'package:servicar_movil/src/models/usuario.dart';
import 'package:servicar_movil/src/widgets/admin_screen.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';
import 'package:servicar_movil/src/widgets/register_appointment.dart';
import 'package:servicar_movil/src/widgets/register_evaluation.dart';

class InfoCita extends StatefulWidget {
  final String id;

  const InfoCita({super.key, required this.id});

  @override
  _InfoCitaState createState() => _InfoCitaState();
}

class _InfoCitaState extends State<InfoCita> {
  late Future<Cita> _detalleCita;
  late Future<String> _nombreServicio;
  final CitasController _citaController = CitasController();
  final UsuarioController _usuarioController = UsuarioController(); // Instancia de UsuarioController
  Usuario? _usuarioActual;

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    // Formatea la fecha como prefieras. Ejemplo: 20 de enero de 2024, 5:00 PM
    String formattedDate = DateFormat('h:mm a', 'es_ES').format(date);

    return formattedDate;
  }

  void _handleEditar(BuildContext context) async {
    final bool? updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => RegisterAppointment(citaId: widget.id),
      ),
    );

    // Si la cita se actualizó correctamente, recarga los datos.
    if (updated == true) {
      setState(() {
        _detalleCita = _citaController.obtenerDetalleCita(widget.id);
        _detalleCita.then((cita) {
          _nombreServicio =
              ServicioController().obtenerNombreServicioPorId(cita.idServicio);
        });
      });
    }
  }

  void _handleEvaluarCita(BuildContext context) async {
    // Primero, obtener los detalles de la cita para verificar si ya fue evaluada
    _citaController.obtenerDetalleCita(widget.id).then((cita) {
      if (cita.evaluada) {
        // Si la cita ya ha sido evaluada, mostrar un diálogo/alerta
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Evaluación ya realizada"),
              content: const Text("Esta cita ya ha sido evaluada."),
              actions: <Widget>[
                TextButton(
                  child: const Text("Aceptar"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Si la cita no ha sido evaluada, permitir evaluar
        Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => RegisterEvaluation(citaId: widget.id),
          ),
        );
      }
    }).catchError((error) {
      // Manejar errores, por ejemplo, mostrar un Snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al verificar la cita: $error'),
        backgroundColor: Colors.red,
      ));
    });
  }
  Future<void> _cargarUsuarioActual() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      // Aquí asumimos que tienes algún método para obtener el UID del usuario actual. Ajusta según tu implementación.
      String uid = auth.currentUser!.uid;
      Usuario usuario = await _usuarioController.obtenerUsuario(uid);
      setState(() {
        _usuarioActual = usuario;
      });
    } catch (e) {
      print("Error al cargar el usuario actual: $e");
    }
  }
  void _handleCancelar(BuildContext context, String idCita) async {
    // Mostrar cuadro de diálogo de confirmación
    bool confirmado = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas cancelar esta cita?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No confirmado
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmado
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    // Si el usuario confirma la eliminación, elimina la cita
    if (confirmado == true) {
      _citaController.eliminarCitaPorId(idCita).then((value) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('La cita ha sido cancelada.'),
          backgroundColor: Colors.green,
        ));
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cancelar la cita: $e'),
          backgroundColor: Colors.red,
        ));
      });
    }
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

  @override
  void initState() {
    super.initState();
    _detalleCita = _citaController.obtenerDetalleCita(widget.id);
    _detalleCita.then((cita) {
      _nombreServicio =
          ServicioController().obtenerNombreServicioPorId(cita.idServicio);
    });
    _cargarUsuarioActual();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de la Cita'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Al presionar la flecha de atrás, se retorna false a la página anterior.
               if (_usuarioActual!.rol == 'admin'){
                Navigator.of(context).pushNamed(
                                             AdminScreen.routeName);
               }else{
                Navigator.of(context).pushNamed(
                                            DashboardScreen.routeName);
               }   
            },
          ),
          // El resto de tu AppBar como acciones, título, etc.
        ),
        body: FutureBuilder<Cita>(
          future: _detalleCita,
          builder: (context, snapshotCita) {
            if (snapshotCita.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshotCita.hasError) {
              return const Center(
                  child: Text('Error al cargar los detalles de la cita'));
            } else if (snapshotCita.hasData) {
              // Ahora cargamos el nombre del servicio con otro FutureBuilder
              return FutureBuilder<String>(
                future:
                    _nombreServicio, // Asegúrate de que este future se inicia en initState()
                builder: (context, snapshotNombreServicio) {
                  if (snapshotNombreServicio.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshotNombreServicio.hasError) {
                    return const Center(
                        child: Text('Error al cargar el nombre del servicio'));
                  } else {
                    // Todo está cargado, procedemos a construir la UI
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            // Asegurar que todo el contenido esté centrado horizontalmente
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getDayTimestamp(
                                          snapshotCita.data!.fechaHoraInicio),
                                      style: const TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF673AB7)),
                                    ),
                                    Text(
                                      getMonthTimestamp(
                                          snapshotCita.data!.fechaHoraInicio),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF673AB7)),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                // Este Expanded se elimina si deseas un centrado más ajustado al contenido
                                Expanded(
                                  child: Text(
                                    snapshotNombreServicio.data!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _quoteDetailRow(
                            title: 'Estado',
                            value: snapshotCita.data!.estado,
                          ),
                          _quoteDetailRow(
                            title: 'Inicio',
                            value: formatTimestamp(
                                snapshotCita.data!.fechaHoraInicio),
                          ),
                          _quoteDetailRow(
                            title: 'Finalización',
                            value: formatTimestamp(
                                snapshotCita.data!.fechaHoraFin),
                          ),
                          const SizedBox(height: 20),
                          if (_usuarioActual != null && _usuarioActual!.rol == 'admin') ...[
                          ElevatedButton(
                            onPressed: () {
                              _handleCompletarCita(context, snapshotCita.data!.idCita);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8), // Rounded corners
                              ),
                              elevation: 5, // Shadow depth
                            ),
                            child: const Text('Completar Cita'),
                          ),
                        ] else ...[
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: 
                                ElevatedButton(
                                  onPressed: () {
                                    _handleEditar(context);
                                  },
                                  child: const Text('Editar'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _handleCancelar(
                                        context, snapshotCita.data!.idCita);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text('Cancelar Cita'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (!snapshotCita.data!.evaluada)
                          ElevatedButton(
                            onPressed: () {
                              _handleEvaluarCita(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8), // Rounded corners
                              ),
                              elevation: 5, // Shadow depth
                            ),
                            child: const Text('Evaluar Cita'),
                          ),
                        ],
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              return const Center(
                  child: Text('No se encontraron detalles de la cita'));
            }
          },
        ),
      ),
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return false;
      },
    );
  }
}

Widget _quoteDetailRow({required String title, required String value}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
  );
void _handleCompletarCita(BuildContext context, String idCita) {
  // Mostrar cuadro de diálogo para confirmación
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Acción'),
        content: const Text('¿Marcar esta cita como completada?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Confirmar'),
            onPressed: () async {
              // Aquí actualizas el estado de la cita en Firestore
              try {
                await CitasController().actualizarEstadoCita(idCita, 'completado');
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed(
                                             AdminScreen.routeName); // Cierra el diálogo de confirmación
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita marcada como completada.'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Opcionalmente, puedes recargar los datos de la cita o volver a la pantalla anterior
              }catch (e) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // Cierra el diálogo de confirmación
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar el estado de la cita: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}