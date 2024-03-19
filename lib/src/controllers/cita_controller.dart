import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/cita.dart';
import '../models/servicio.dart';

class CitasController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para crear una nueva cita
  Future<void> crearCita(Cita cita) async {
    // Obtener el usuario actualmente autenticado
    User? usuarioActual = FirebaseAuth.instance.currentUser;
    String? emailDestinatario = usuarioActual?.email;

    if (emailDestinatario != null) {
      // Crear la cita en la colección 'citas'
      DocumentReference refCita =
          await _db.collection('citas').add(cita.toJson());
      // Actualiza el documento de la cita con el ID generado
      await refCita.update({'idCita': refCita.id});

      // Obtener el documento del servicio basado en el idServicio
      DocumentSnapshot servicioDoc =
          await _db.collection('servicios').doc(cita.idServicio).get();
      // Decodificar el documento a una instancia de Servicio
      Servicio servicio =
          Servicio.fromJson(servicioDoc.data() as Map<String, dynamic>);

      // Construir el mensaje del correo electrónico usando el modelo Servicio
      String asunto = "Confirmación de Cita";
      String mensaje =
          "Estimado $emailDestinatario, su cita para ${servicio.nombre} el día ${cita.fechaHoraInicio.toDate()} - ${cita.fechaHoraFin.toDate()} ha sido agendada.";

      // Crear el item en la colección 'mail' para el Trigger Email
      await _db.collection('mail').add({
        'to': emailDestinatario, // Destinatario del correo
        'message': {
          'subject': asunto, // Asunto del correo
          'text': mensaje // Cuerpo del correo
        }
      });
    } else {
      // Manejar el caso de que no haya un usuario autenticado
      print("No hay un usuario autenticado para enviar el correo.");
    }
  }

  Future<void> verificarCitasYEnviarRecordatorios() async {
    final User? usuarioActual = FirebaseAuth.instance.currentUser;
    final String? emailDestinatario = usuarioActual?.email;

    if (emailDestinatario == null) {
      print("No hay un usuario autenticado.");
      return;
    }

    // Obtener la fecha y hora actuales
    final DateTime now = DateTime.now();
    // Calcular 4 horas después del momento actual
    final DateTime fourHoursFromNow = now.add(const Duration(hours: 4));

    // Obtener citas próximas dentro de las próximas 4 horas
    final QuerySnapshot citasSnapshot = await _db
        .collection('citas')
        .where('fechaHoraInicio', isGreaterThanOrEqualTo: now)
        .where('fechaHoraInicio', isLessThan: fourHoursFromNow)
        .get();

    for (var doc in citasSnapshot.docs) {
      final Map<String, dynamic> citaData = doc.data() as Map<String, dynamic>;
      final Cita cita = Cita.fromJson(citaData);

      // Obtener el documento del servicio basado en el idServicio
      DocumentSnapshot servicioDoc =
          await _db.collection('servicios').doc(cita.idServicio).get();
      if (!servicioDoc.exists) {
        print("Documento de servicio no encontrado.");
        continue;
      }
      // Decodificar el documento a una instancia de Servicio
      final Servicio servicio =
          Servicio.fromJson(servicioDoc.data() as Map<String, dynamic>);

      // Construir el mensaje del correo electrónico
      String asunto = "Recordatorio de Cita";
      String mensaje =
          "Estimado $emailDestinatario, le recordamos que su cita para ${servicio.nombre} es dentro de menos de 4 horas, a las ${cita.fechaHoraInicio.toDate()}.";

      // Crear el item en la colección 'mail' para el Trigger Email
      await _db.collection('mail').add({
        'to': emailDestinatario,
        'message': {
          'subject': asunto,
          'text': mensaje,
        },
      });
    }
  }

  // Método para editar una cita existente
  Future<void> editarCita(Cita cita) async {
    await _db.collection('citas').doc(cita.idCita).update(cita.toJson());
  }
  Future<void> actualizarEstadoCita(String idCita, String nuevoEstado) async {
  await _db.collection('citas').doc(idCita).update({'estado': nuevoEstado});
}

  Future<void> eliminarCitaPorId(String idCita) async {
    await _db.collection('citas').doc(idCita).delete();
  }

  Future<Cita> obtenerDetalleCita(String idCita) async {
    DocumentSnapshot docSnapshot =
        await _db.collection('citas').doc(idCita).get();

    if (docSnapshot.exists) {
      // Utiliza Cita.fromJson para convertir los datos del documento en una instancia de Cita.
      // Asegúrate de incluir el 'idCita' en el mapa, ya que Firestore no lo incluye por defecto.
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      data['idCita'] =
          docSnapshot.id; // Asegura que el idCita se incluya en los datos.

      Cita cita = Cita.fromJson(data);
      return cita;
    } else {
      throw Exception('La cita no existe');
    }
  }

  // Método para obtener citas por trabajador y fecha
  Future<List<Cita>> obtenerCitasPorTrabajadorYFecha(
      String idTrabajador, DateTime fecha) async {
    DateTime inicioDelDia = DateTime(fecha.year, fecha.month, fecha.day);
    DateTime finDelDia =
        DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

    // Primero, obtén todas las citas para el trabajador que comienzan en el día seleccionado.
    QuerySnapshot querySnapshot = await _db
        .collection('citas')
        .where('idTrabajador', isEqualTo: idTrabajador)
        .where('fechaHoraInicio', isGreaterThanOrEqualTo: inicioDelDia)
        .where('fechaHoraInicio',
            isLessThanOrEqualTo:
                finDelDia) // Cambiado a fechaHoraInicio para cumplir con Firestore
        .get();

    // Luego, opcionalmente, filtra en el cliente las citas que no terminan dentro del día seleccionado si es necesario.
    // Esta parte es opcional y depende de si necesitas asegurarte de que las citas también terminen dentro del día seleccionado.
    var citas = querySnapshot.docs
        .map((doc) => Cita.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Filtrado opcional en el cliente para citas que terminan dentro del día seleccionado.
    // citas = citas.where((cita) => cita.fechaHoraFin.isBefore(finDelDia.add(Duration(days: 1))) && cita.fechaHoraFin.isAfter(inicioDelDia)).toList();

    return citas;
  }

  Future<List<Cita>> obtenerCitasPorUsuario(String uid) async {
    try {
      // Intenta obtener todas las citas para el usuario especificado.
      QuerySnapshot querySnapshot = await _db
          .collection('citas')
          .where('idCliente', isEqualTo: uid)
          .get();

      // Si no hay documentos, retorna una lista vacía y opcionalmente maneja este caso.
      if (querySnapshot.docs.isEmpty) {
        // Puedes manejar el caso de "sin resultados" aquí si es necesario, por ejemplo, registrando un mensaje.
        print('No se encontraron citas para el usuario con UID: $uid');
        return [];
      }

      // Convierte los documentos de Firestore en objetos Cita.
      var citas = querySnapshot.docs
          .map((doc) => Cita.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return citas;
    } catch (e) {
      // Maneja cualquier error que ocurra durante la consulta o el procesamiento de los datos.
      print(
          'Ocurrió un error al obtener las citas para el usuario con UID: $uid. Error: $e');
      // Opcionalmente, puedes lanzar una excepción personalizada o devolver una lista vacía.
      throw Exception('Error al obtener las citas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCitasDetails() async {
    QuerySnapshot citasSnapshot = await _db.collection('citas').get();

    List<Future<Map<String, dynamic>>> citasDetailsFutures =
        citasSnapshot.docs.map((doc) async {
      Map<String, dynamic> cita = doc.data() as Map<String, dynamic>;

      // Obtener el nombre del servicio
      DocumentSnapshot servicioSnapshot =
          await _db.collection('servicios').doc(cita['idServicio']).get();
      Map<String, dynamic>? servicioData =
          servicioSnapshot.data() as Map<String, dynamic>?;
      String nombreServicio = servicioData?['nombre'] ?? 'Desconocido';

      // Obtener el nombre del cliente
      DocumentSnapshot clienteSnapshot =
          await _db.collection('usuarios').doc(cita['idCliente']).get();
      Map<String, dynamic>? clienteData =
          clienteSnapshot.data() as Map<String, dynamic>?;
      String nombreCliente = clienteData != null
          ? "${clienteData['nombre']} ${clienteData['apellido']}"
          : 'Desconocido';

      // Obtener el nombre del trabajador
      DocumentSnapshot trabajadorSnapshot =
          await _db.collection('trabajadores').doc(cita['idTrabajador']).get();
      Map<String, dynamic>? trabajadorData =
          trabajadorSnapshot.data() as Map<String, dynamic>?;
      String nombreTrabajador = trabajadorData?['nombre'] ?? 'Desconocido';

      // Agrega la información al mapa de la cita
      cita['nombreServicio'] = nombreServicio;
      cita['nombreCliente'] = nombreCliente;
      cita['nombreTrabajador'] = nombreTrabajador;
      print(cita['idCita']);

      return cita;
    }).toList();

    return await Future.wait(citasDetailsFutures);
  }
  Future<List<Map<String, dynamic>>> getCitasPendientesDetails() async {
    // Se modifica esta línea para incluir el filtro por el estado "pendiente"
    QuerySnapshot citasSnapshot = await _db.collection('citas').where('estado', isEqualTo: 'pendiente').get();

    List<Future<Map<String, dynamic>>> citasDetailsFutures = citasSnapshot.docs.map((doc) async {
      Map<String, dynamic> cita = doc.data() as Map<String, dynamic>;

      // Obtener el nombre del servicio
      DocumentSnapshot servicioSnapshot = await _db.collection('servicios').doc(cita['idServicio']).get();
      Map<String, dynamic>? servicioData = servicioSnapshot.data() as Map<String, dynamic>?;
      String nombreServicio = servicioData?['nombre'] ?? 'Desconocido';

      // Obtener el nombre del cliente
      DocumentSnapshot clienteSnapshot = await _db.collection('usuarios').doc(cita['idCliente']).get();
      Map<String, dynamic>? clienteData = clienteSnapshot.data() as Map<String, dynamic>?;
      String nombreCliente = clienteData != null ? "${clienteData['nombre']} ${clienteData['apellido']}" : 'Desconocido';

      // Obtener el nombre del trabajador
      DocumentSnapshot trabajadorSnapshot = await _db.collection('trabajadores').doc(cita['idTrabajador']).get();
      Map<String, dynamic>? trabajadorData = trabajadorSnapshot.data() as Map<String, dynamic>?;
      String nombreTrabajador = trabajadorData?['nombre'] ?? 'Desconocido';

      // Agrega la información al mapa de la cita
      cita['nombreServicio'] = nombreServicio;
      cita['nombreCliente'] = nombreCliente;
      cita['nombreTrabajador'] = nombreTrabajador;

      return cita;
    }).toList();

    return await Future.wait(citasDetailsFutures);
  }

}
