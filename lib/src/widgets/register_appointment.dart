// Task: Formulario Registro de Citas
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servicar_movil/src/models/servicio.dart';
import 'package:servicar_movil/src/models/trabajador.dart';
import 'package:servicar_movil/src/models/area.dart';
import 'package:servicar_movil/src/models/cita.dart';
import 'package:servicar_movil/src/controllers/area_controller.dart';
import 'package:servicar_movil/src/controllers/cita_controller.dart';
import 'package:servicar_movil/src/controllers/servicio_controller.dart';
import 'package:servicar_movil/src/controllers/trabajador_controller.dart';
import 'package:collection/collection.dart';
import 'package:servicar_movil/src/widgets/date_picker_form_field.dart';

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

  @override
  void initState() {
    super.initState();
    cargarAreas();
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

    // Obtén las citas existentes para el trabajador en la fecha seleccionada.
    final List<Cita> citasDelDia =
        await CitasController().obtenerCitasPorTrabajadorYFecha(
      selectedWorkerId!,
      selectedDate!,
    );

    // Aquí debes calcular los horarios de trabajo del trabajador seleccionado.
    // Para este ejemplo, asumiremos un horario fijo de 9:00 a 17:00.
    List<String> horariosTrabajo =
        generarHorariosTrabajo(9, 17, duracionServicio);

    // Excluye los horarios ocupados por las citas existentes.
    availableTimes = filtrarHorariosDisponibles(
        horariosTrabajo, citasDelDia, duracionServicio);

    setState(() {});
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
    // Aquí debes excluir los horarios que se solapen con las citas existentes.
    // Esta implementación depende de cómo estés almacenando las horas (como strings, DateTime, etc.).
    // Debes convertir las horas de inicio y fin de las citas a DateTime y compararlas con los horarios de trabajo generados.
    return horariosTrabajo; // Retorna la lista filtrada.
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
                  Color(0xFF673AB7), // Start color
                  Color.fromRGBO(124, 77, 255, 1), // End color
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
                        const DatePickeFormField(),
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
                        SizedBox(
                          width: double.infinity, // Ancho del 100%
                          child: ElevatedButton(
                            onPressed: () {},
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
