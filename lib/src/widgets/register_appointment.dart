// Task: Formulario Registro de Citas
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servicar_movil/src/models/rango_horario.dart';
import 'package:servicar_movil/src/models/servicio.dart';
import 'package:servicar_movil/src/models/trabajador.dart';
import 'package:servicar_movil/src/models/area.dart';
import 'package:servicar_movil/src/models/cita.dart';
import 'package:servicar_movil/src/controllers/area_controller.dart';
import 'package:servicar_movil/src/controllers/cita_controller.dart';
import 'package:servicar_movil/src/controllers/servicio_controller.dart';
import 'package:servicar_movil/src/controllers/trabajador_controller.dart';
import 'package:collection/collection.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';
import 'package:servicar_movil/src/widgets/date_picker_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterAppointment extends StatefulWidget {
  final String? citaId; // ID de la cita para edición, null si es nueva cita.
  static const String routeName = '/register_appointment';

  const RegisterAppointment({super.key, this.citaId});

  @override
  State<RegisterAppointment> createState() => _RegisterAppointmentState();
}

class _RegisterAppointmentState extends State<RegisterAppointment> {
  String? selectedAreaId = '';
  String? selectedServiceId = '';
  String? selectedWorkerId = '';
  DateTime? selectedDate;
  String? selectedTimeSlot;
  List<Area> areas = [];
  List<Servicio> servicios = [];
  List<Trabajador> trabajadores = [];
  List<String> availableTimes = [];
  late FirebaseAuth _auth2;
  late String uid;
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    inicializarFormulario();
    super.initState();
    _auth2 = FirebaseAuth.instance;
    uid = _auth2.currentUser!.uid;
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<void> inicializarFormulario() async {
    await cargarAreas();

    if (widget.citaId != null) {
      await cargarDatosCitaExistente();
    }
  }

  Future<void> cargarDatosCitaExistente() async {
    // Obtén los detalles de la cita existente.
    final cita = await CitasController().obtenerDetalleCita(widget.citaId!);
    final Servicio service =
        await ServicioController().obtenerServicioPorId(cita.idServicio);
    print(service.idArea);
    await cargarServiciosPorArea(service.idArea);
    await cargarTrabajadoresPorArea(service.idArea);
    print(cita.fechaHoraInicio.toDate());

    setState(() {
      selectedAreaId = service.idArea;
      selectedServiceId = service.idServicio;
      selectedWorkerId = cita.idTrabajador;
      selectedDate = cita.fechaHoraInicio.toDate();
      // Actualiza el controlador de texto con la fecha de la cita
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    });
    Future.microtask(() async {
      await calcularHorariosDisponibles();
    });
  }

  Future<void> cargarAreas() async {
    areas = await AreaController().obtenerAreas();
    if (areas.isNotEmpty) {
      setState(() {});
    }
  }

  Future<void> cargarServiciosPorArea(String idArea) async {
    if (idArea.isEmpty) {
      servicios = [];
      selectedServiceId = ""; // Establecer como vacío
    } else {
      servicios = await ServicioController().obtenerServiciosPorArea(idArea);
      if (servicios.isNotEmpty) {
        selectedServiceId = ""; // Ningún servicio disponible
      }
    }
    setState(() {});
  }

  Future<void> cargarTrabajadoresPorArea(String idArea) async {
    if (idArea.isEmpty) {
      trabajadores = [];
      selectedWorkerId = ""; // Establecer como vacío
    } else {
      trabajadores =
          await TrabajadorController().obtenerTrabajadoresPorArea(idArea);
      if (trabajadores.isNotEmpty) {
        selectedWorkerId = ""; // Primer trabajador por defecto
      }
    }
    setState(() {});
  }

  Future<void> calcularHorariosDisponibles() async {
    if (selectedWorkerId == null ||
        selectedServiceId == null ||
        selectedDate == null) {
      return; // Asegúrate de que todos los datos necesarios estén seleccionados.
    }

    // Obtén la duración del servicio seleccionado.
    final Servicio? servicioSeleccionado = servicios.firstWhereOrNull(
      (servicio) => servicio.idServicio == selectedServiceId,
    );

    if (servicioSeleccionado == null) return;

    final int duracionServicio = int.parse(servicioSeleccionado.duracion);

    final List<Cita> citasDelDia =
        await CitasController().obtenerCitasPorTrabajadorYFecha(
      selectedWorkerId!,
      selectedDate!,
    );

    // Aquí debes calcular los horarios de trabajo del trabajador seleccionado.
    // Para este ejemplo, asumiremos un horario fijo de 9:00 a 17:00.
    List<String> horariosTrabajo =
        generarHorariosTrabajo(8, 18, duracionServicio);

    // Excluye los horarios ocupados por las citas existentes.
    availableTimes = filtrarHorariosDisponibles(
        horariosTrabajo, citasDelDia, duracionServicio);

    setState(() {});
  }

  RangoHorario convertirRangoATimestamps(String rangoHorario) {
    // Intenta parsear las fechas y manejar cualquier error que pueda ocurrir
    try {
      // Dividir el rango en hora de inicio y fin basado en el nuevo formato
      List<String> partes = rangoHorario.split(' - ');
      if (partes.length != 2) {
        throw FormatException('El rango horario no tiene el formato correcto.');
      }

      // Especificar el formato de fecha y hora
      DateFormat formato = DateFormat("EEE, d MMM HH:mm yyyy", "en_US_POSIX");

      DateTime inicioDateTime = formato.parse(partes[0], true).toLocal();
      DateTime finDateTime = formato.parse(partes[1], true).toLocal();

      // Ajustar la fecha de fin si es necesario
      if (finDateTime.isBefore(inicioDateTime)) {
        finDateTime = DateTime(finDateTime.year, finDateTime.month,
            inicioDateTime.day + 1, finDateTime.hour, finDateTime.minute);
      }

      Timestamp inicioTimestamp = Timestamp.fromDate(inicioDateTime);
      Timestamp finTimestamp = Timestamp.fromDate(finDateTime);

      print('Inicio Timestamp: ${inicioTimestamp.toString()}');
      print('Fin Timestamp: ${finTimestamp.toString()}');

      return RangoHorario(inicio: inicioTimestamp, fin: finTimestamp);
    } catch (e) {
      print('Error al convertir rango horario: $e');
      rethrow; // Propagar el error si es necesario.
    }
  }

  List<String> generarHorariosTrabajo(
      int horaInicio, int horaFin, int duracionServicio) {
    List<String> horarios = [];
    DateTime inicio = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day, horaInicio);
    final DateTime fin = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day, horaFin);

    do {
      DateTime posibleFin = inicio.add(Duration(minutes: duracionServicio));
      // Ajustar el formato para incluir el día si es necesario
      String horarioInicio = DateFormat('E, d MMM HH:mm').format(inicio);
      String horarioFin = DateFormat('E, d MMM HH:mm').format(posibleFin);

      horarios.add('$horarioInicio - $horarioFin');
      inicio = posibleFin;

      if (inicio.hour >= horaFin || !inicio.isBefore(fin)) {
        inicio =
            DateTime(inicio.year, inicio.month, inicio.day + 1, horaInicio);
      }
    } while (inicio.isBefore(fin) || inicio.compareTo(fin) == 0);

    return horarios;
  }

  List<String> filtrarHorariosDisponibles(List<String> horariosTrabajo,
      List<Cita> citasDelDia, int duracionServicio) {
    List<String> horariosDisponibles = [];
    for (var horario in horariosTrabajo) {
      bool esDisponible = true;
      final partesHorario = horario.split(' - ');
      final fechaHoraInicioHorario =
          DateFormat('E, d MMM HH:mm').parse(partesHorario[0], true);
      final fechaHoraFinHorario =
          DateFormat('E, d MMM HH:mm').parse(partesHorario[1], true);

      for (var cita in citasDelDia) {
        DateTime inicioCita = cita.fechaHoraInicio.toDate();
        DateTime finCita = cita.fechaHoraFin.toDate();

        if (!(fechaHoraFinHorario.isBefore(inicioCita) ||
            fechaHoraInicioHorario.isAfter(finCita))) {
          esDisponible = false;
          break;
        }
      }
      if (esDisponible) {
        horariosDisponibles.add(horario);
      }
    }
    return horariosDisponibles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Nueva Cita'),
        ),
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
            child: Stack(
              children: [
                Column(children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: <Widget>[
                        //Dropdown para seleccionar el area
                        DropdownButtonFormField<String>(
                          value: selectedAreaId,
                          onChanged: (newValue) {
                            setState(() {
                              selectedAreaId = newValue ?? '';
                              if (newValue != null && newValue.isNotEmpty) {
                                cargarServiciosPorArea(newValue);
                                cargarTrabajadoresPorArea(newValue);
                              }
                            });
                          },
                          items: [
                            const DropdownMenuItem<String>(
                              value: '', // Valor nulo para "--Seleccione--"
                              child: Text("-- Seleccione --"),
                            ),
                            ...areas.map<DropdownMenuItem<String>>((Area area) {
                              return DropdownMenuItem<String>(
                                value: area.idArea,
                                child: Text(area.nombre),
                              );
                            }),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Área',
                            prefixIcon: Icon(Icons.car_repair),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Dropdown para seleccionar el servicio
                        DropdownButtonFormField<String>(
                          value: selectedServiceId, // Maneja la selección nula.
                          onChanged: (newValue) {
                            setState(() {
                              selectedServiceId = newValue!;
                              // Aquí podrías cargar información adicional basada en el servicio seleccionado si fuera necesario
                            });
                          },
                          items: [
                            const DropdownMenuItem<String>(
                              value: "", // Valor especial que actúa como nulo.
                              child: Text("-- Seleccione --"),
                            ),
                            ...servicios.map<DropdownMenuItem<String>>(
                                (Servicio servicio) {
                              return DropdownMenuItem<String>(
                                value: servicio
                                    .idServicio, // Asumiendo que Servicio tiene un campo idServicio
                                child:
                                    Text(servicio.nombre), // y un campo nombre
                              );
                            }),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Servicio',
                            prefixIcon: Icon(Icons.car_crash),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Dropdown para seleccionar el trabajador
                        DropdownButtonFormField<String>(
                          value: selectedWorkerId,
                          onChanged: (newValue) {
                            setState(() {
                              selectedWorkerId = newValue!;
                              calcularHorariosDisponibles();
                              // Aquí podrías realizar acciones adicionales basadas en el trabajador seleccionado si es necesario
                            });
                          },
                          items: [
                            const DropdownMenuItem<String>(
                              value: "", // Valor especial que actúa como nulo.
                              child: Text("-- Seleccione --"),
                            ),
                            ...trabajadores.map<DropdownMenuItem<String>>(
                                (Trabajador trabajador) {
                              return DropdownMenuItem<String>(
                                value: trabajador
                                    .idTrabajador, // Asumiendo que Trabajador tiene un campo idTrabajador
                                child: Text(
                                    trabajador.nombre), // y un campo nombre
                              );
                            }).toList(),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Trabajador',
                            prefixIcon: Icon(Icons.work),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Selector de fecha

                        DatePickerFormField(
                          controller: dateController,
                          onDateSelected: (DateTime date) {
                            setState(() {
                              selectedDate = date;
                              // Actualiza cualquier otro estado necesario aquí
                            });
                          },
                        ),

                        const SizedBox(height: 20),
                        // Selector de hora
                        DropdownButtonFormField<String>(
                          value:
                              selectedTimeSlot, // Asegúrate de manejar este estado correctamente
                          onChanged: (newValue) {
                            setState(() {
                              selectedTimeSlot = newValue;
                              print(newValue);
                            });
                          },
                          items: availableTimes
                              .map<DropdownMenuItem<String>>((String time) {
                            return DropdownMenuItem<String>(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Horario Disponible',
                            prefixIcon: Icon(Icons.query_builder),
                          ),
                        ),

                        const SizedBox(height: 30),
                        // Botón para enviar/agendar la cita
                        // Botón para enviar/agendar la cita
                        SizedBox(
                          width: double.infinity, // Ancho del 100%
                          child: ElevatedButton(
                            onPressed: selectedTimeSlot != null
                                ? () async {
                                    // Aquí, convertir el horario seleccionado a Timestamps de inicio y fin
                                    RangoHorario rangoHorario =
                                        convertirRangoATimestamps(
                                            selectedTimeSlot!);

                                    // Crear el objeto Cita
                                    Cita cita = Cita(
                                      idCita: widget.citaId ??
                                          '', // Este valor se actualizará después de crear la cita en Firestore
                                      idCliente:
                                          uid, // Deberás reemplazar esto con el ID real del cliente
                                      idServicio:
                                          selectedServiceId!, // ID del servicio seleccionado
                                      idTrabajador:
                                          selectedWorkerId!, // ID del trabajador seleccionado
                                      fechaHoraInicio: rangoHorario.inicio,
                                      fechaHoraFin: rangoHorario.fin,
                                      estado:
                                          'pendiente', // Estado inicial de la cita
                                      evaluada: false,
                                    );
                                    if (widget.citaId != null) {
                                      // Estás editando una cita existente
                                      await CitasController()
                                          .editarCita(cita)
                                          .then((_) {
                                        // Mostrar un mensaje de éxito
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Cita actualizada con éxito')),
                                        );
                                        // Navegar de regreso al dashboard o la pantalla anterior
                                        Navigator.of(context).pushNamed(
                                            DashboardScreen.routeName);
                                      }).catchError((error) {
                                        // Manejar el error, por ejemplo, mostrando un mensaje
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error al actualizar la cita: $error')),
                                        );
                                      });
                                    } else {
                                      // Crear una nueva cita
                                      await CitasController()
                                          .crearCita(cita)
                                          .then((_) {
                                        // Mostrar un mensaje de éxito
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Cita agendada con éxito')),
                                        );
                                        // Navegar de regreso al dashboard o la pantalla anterior
                                        Navigator.of(context).pushNamed(
                                            DashboardScreen.routeName);
                                      }).catchError((error) {
                                        // Manejar el error
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error al crear la cita: $error')),
                                        );
                                      });
                                    }
                                  }
                                : null,
                            child: const Text('AGENDAR'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])
              ],
            )));
  }
}
