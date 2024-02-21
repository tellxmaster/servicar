import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cita.dart';

class CitasController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para crear una nueva cita
  Future<void> crearCita(Cita cita) async {
    DocumentReference ref = await _db.collection('citas').add(cita.toJson());
    // Opcionalmente, actualiza el documento con el ID generado si es necesario
    await ref.update({'idCita': ref.id});
  }

  // Método para editar una cita existente
  Future<void> editarCita(Cita cita) async {
    await _db.collection('citas').doc(cita.idCita).update(cita.toJson());
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
      print('Ocurrió un error al obtener las citas para el usuario con UID: $uid. Error: $e');
      // Opcionalmente, puedes lanzar una excepción personalizada o devolver una lista vacía.
      throw Exception('Error al obtener las citas: $e');
    }
  }


}
