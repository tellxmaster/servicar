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
}
