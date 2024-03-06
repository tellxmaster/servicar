import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/servicio.dart'; // Asegúrate de tener este modelo definido

class ServicioController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método existente para obtener todos los servicios
  Future<List<Servicio>> obtenerServicios() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('servicios').get();
      List<Servicio> servicios = querySnapshot.docs
          .map((doc) => Servicio.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return servicios;
    } catch (e) {
      print("Error al obtener servicios: $e");
      throw Exception('Error al obtener servicios');
    }
  }

  // Método nuevo para obtener servicios por área específica
  Future<List<Servicio>> obtenerServiciosPorArea(String idArea) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('servicios')
          .where('idArea', isEqualTo: idArea)
          .get();
      List<Servicio> servicios = querySnapshot.docs
          .map((doc) => Servicio.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return servicios;
    } catch (e) {
      print("Error al obtener servicios por área $idArea: $e");
      throw Exception('Error al obtener servicios por área');
    }
  }

  Future<String> obtenerServicioPoridServicio(String idServicio) async {
    DocumentSnapshot doc =
        await _db.collection('servicios').doc(idServicio).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['nombre'] ??
          ''; // Reemplaza 'modelo' con el nombre de campo que estés usando para el modelo del auto
    } else {
      throw Exception('Servicio no encontrado');
    }
  }

  Future<String> obtenerNombreServicioPorId(String idServicio) async {
    try {
      DocumentSnapshot servicioDoc =
          await _db.collection('servicios').doc(idServicio).get();
      if (servicioDoc.exists) {
        Map<String, dynamic> data = servicioDoc.data() as Map<String, dynamic>;
        String nombreServicio = data['nombre'] as String;
        return nombreServicio;
      } else {
        throw Exception('Servicio no encontrado');
      }
    } catch (e) {
      throw Exception('Error al obtener el servicio: $e');
    }
  }
}
