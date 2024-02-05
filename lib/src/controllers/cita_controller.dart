import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cita.dart'; // Asume que tienes este modelo definido

class CitasController {
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
}
