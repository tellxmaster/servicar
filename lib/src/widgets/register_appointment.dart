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
  static const String routeName = '/register_appointment';

  const RegisterAppointment({super.key});

  @override
  State<RegisterAppointment> createState() => _RegisterAppointmentState();
}

class _RegisterAppointmentState extends State<RegisterAppointment> {
  String? selectedAreaId = '';
  String? selectedServiceId = '';
  String? selectedWorkerId = '';
  DateTime? selectedDate = DateTime.now();
  String? selectedTimeSlot;
  List<Area> areas = [];
  List<Servicio> servicios = [];
  List<Trabajador> trabajadores = [];
  List<String> availableTimes = [];
  late FirebaseAuth _auth2;
  late String uid;

  @override
  void initState() {
    super.initState();
    cargarAreas();
    _auth2 = FirebaseAuth.instance;
    uid = _auth2.currentUser!.uid;
  }

  void cargarAreas() async {
    areas = await AreaController()
        .obtenerAreas(); // Asume que este método existe y funciona correctamente
    if (areas.isNotEmpty) {
      selectedAreaId =
          areas.first.idArea; // Selecciona por defecto el primer área
      cargarServiciosPorArea(selectedAreaId!);
      cargarTrabajadoresPorArea(selectedAreaId!);
    }
    setState(() {});
  }

  void cargarServiciosPorArea(String idArea) async {
    servicios = await ServicioController().obtenerServiciosPorArea(idArea);
    if (servicios.isNotEmpty) {
      selectedServiceId = servicios
          .first.idServicio; // Selecciona por defecto el primer servicio
    }
    setState(() {});
  }

  void cargarTrabajadoresPorArea(String idArea) async {
    trabajadores =
        await TrabajadorController().obtenerTrabajadoresPorArea(idArea);
    if (trabajadores.isNotEmpty) {
      selectedWorkerId = trabajadores
          .first.idTrabajador; // Selecciona por defecto el primer trabajador
    }
    setState(() {});
  }

  void calcularHorariosDisponibles() async {
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

    final int duracionServicio = servicioSeleccionado.duracion;

    final List<Cita> citasDelDia =
        await CitasController().obtenerCitasPorTrabajadorYFecha(
      selectedWorkerId!,
      selectedDate!,
    );

    print(selectedWorkerId);
    print(selectedServiceId);
    print(selectedDate);
    print(citasDelDia);

    // Aquí debes calcular los horarios de trabajo del trabajador seleccionado.
    // Para este ejemplo, asumiremos un horario fijo de 9:00 a 17:00.
    List<String> horariosTrabajo =
        generarHorariosTrabajo(8, 16, duracionServicio);

    // Excluye los horarios ocupados por las citas existentes.
    availableTimes = filtrarHorariosDisponibles(
        horariosTrabajo, citasDelDia, duracionServicio);

    setState(() {});
  }

  RangoHorario convertirRangoATimestamps(String rangoHorario) {
    List<String> partes = rangoHorario.split(' - ');
    List<String> horaInicioPartes = partes[0].split(':');
    List<String> horaFinPartes = partes[1].split(':');

    // Usa selectedDate en lugar de DateTime.now()
    DateTime inicioDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        int.parse(horaInicioPartes[0]),
        int.parse(horaInicioPartes[1]));
    DateTime finDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        int.parse(horaFinPartes[0]),
        int.parse(horaFinPartes[1]));

    Timestamp inicioTimestamp = Timestamp.fromDate(inicioDateTime);
    Timestamp finTimestamp = Timestamp.fromDate(finDateTime);

    return RangoHorario(inicio: inicioTimestamp, fin: finTimestamp);
  }

  List<String> generarHorariosTrabajo(
      int horaInicio, int horaFin, int duracionServicio) {
    List<String> horarios = [];
    DateTime inicio = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day, horaInicio);
    final DateTime fin = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day, horaFin);

    while (inicio.add(Duration(minutes: duracionServicio)).isBefore(fin)) {
      String horarioInicio = DateFormat('HH:mm').format(inicio);
      inicio = inicio.add(Duration(minutes: duracionServicio));
      String horarioFin = DateFormat('HH:mm').format(inicio);

      horarios.add('$horarioInicio - $horarioFin');
    }
    return horarios;
  }

  List<String> filtrarHorariosDisponibles(List<String> horariosTrabajo,
      List<Cita> citasDelDia, int duracionServicio) {
    // Convertir rangos de citas a strings en formato "HH:mm - HH:mm"
    List<String> rangosCitas = citasDelDia.map((cita) {
      String inicio =
          "${cita.fechaHoraInicio.toDate().hour.toString().padLeft(2, '0')}:${cita.fechaHoraInicio.toDate().minute.toString().padLeft(2, '0')}";
      String fin =
          "${cita.fechaHoraFin.toDate().hour.toString().padLeft(2, '0')}:${cita.fechaHoraFin.toDate().minute.toString().padLeft(2, '0')}";
      return "$inicio - $fin";
    }).toList();

    List<String> horariosDisponibles = [];

    // Verificar cada horario de trabajo contra los rangos de citas
    for (var horario in horariosTrabajo) {
      bool esDisponible = true;
      for (var rangoCita in rangosCitas) {
        // Dividir los horarios y rangos de citas en inicio y fin
        List<String> horasHorario = horario.split(' - ');
        List<String> horasCita = rangoCita.split(' - ');

        // Convertir a DateTime para comparar
        DateTime inicioHorario = DateTime(
            0,
            0,
            0,
            int.parse(horasHorario[0].split(':')[0]),
            int.parse(horasHorario[0].split(':')[1]));
        DateTime finHorario =
            inicioHorario.add(Duration(minutes: duracionServicio));
        DateTime inicioCita = DateTime(
            0,
            0,
            0,
            int.parse(horasCita[0].split(':')[0]),
            int.parse(horasCita[0].split(':')[1]));
        DateTime finCita = DateTime(
            0,
            0,
            0,
            int.parse(horasCita[1].split(':')[0]),
            int.parse(horasCita[1].split(':')[1]));

        // Comprobar si el horario se solapa con alguna cita
        if (!(finHorario.isBefore(inicioCita) ||
            inicioHorario.isAfter(finCita))) {
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
                              selectedAreaId = newValue;
                              cargarServiciosPorArea(selectedAreaId!);
                              cargarTrabajadoresPorArea(selectedAreaId!);
                            });
                          },
                          items:
                              areas.map<DropdownMenuItem<String>>((Area area) {
                            return DropdownMenuItem<String>(
                              value: area.idArea,
                              child: Text(area.nombre),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Área',
                            prefixIcon: Icon(Icons.car_repair),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Dropdown para seleccionar el servicio
                        DropdownButtonFormField<String>(
                          value: selectedServiceId,
                          onChanged: (newValue) {
                            setState(() {
                              selectedServiceId = newValue;
                              // Aquí podrías cargar información adicional basada en el servicio seleccionado si fuera necesario
                            });
                          },
                          items: servicios.map<DropdownMenuItem<String>>(
                              (Servicio servicio) {
                            return DropdownMenuItem<String>(
                              value: servicio
                                  .idServicio, // Asumiendo que Servicio tiene un campo id
                              child: Text(servicio.nombre), // y un campo nombre
                            );
                          }).toList(),
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
                              selectedWorkerId = newValue;
                              calcularHorariosDisponibles();
                              // Similarmente, podrías cargar más datos basados en el trabajador seleccionado si es necesario
                            });
                          },
                          items: trabajadores.map<DropdownMenuItem<String>>(
                              (Trabajador trabajador) {
                            return DropdownMenuItem<String>(
                              value: trabajador
                                  .idTrabajador, // Asumiendo que Trabajador tiene un campo id
                              child:
                                  Text(trabajador.nombre), // y un campo nombre
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Trabajador',
                            prefixIcon: Icon(Icons.work),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Selector de fecha
                        DatePickerFormField(
                          onDateSelected: (DateTime date) {
                            // Aquí puedes manejar la fecha seleccionada, por ejemplo, actualizar el estado del componente padre
                            selectedDate = date;
                            calcularHorariosDisponibles();
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
                                      idCita:
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
                                    );

                                    // Llamar a la función para crear la cita en Firestore
                                    await CitasController()
                                        .crearCita(cita)
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Cita agendada con éxito'),
                                          backgroundColor: Color(0xFF28A745),
                                        ),
                                      );
                                      Navigator.of(context)
                                          .pushNamed(DashboardScreen.routeName);
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Ocurrió un error: $error'), // Mostrar el error puede ser útil
                                          backgroundColor:
                                              const Color(0xFFdc3545),
                                        ),
                                      );
                                    });
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
