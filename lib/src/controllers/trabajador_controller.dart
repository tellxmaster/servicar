import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/trabajador.dart'; // Asegúrate de tener este modelo definido

class TrabajadorController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para obtener todos los trabajadores
  Future<List<Trabajador>> obtenerTrabajadores() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('trabajadores').get();
      List<Trabajador> trabajadores = querySnapshot.docs
          .map((doc) => Trabajador.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return trabajadores;
    } catch (e) {
      print("Error al obtener trabajadores: $e");
      throw Exception('Error al obtener trabajadores');
    }
  }

  // Método para obtener trabajadores por área específica
  Future<List<Trabajador>> obtenerTrabajadoresPorArea(String idArea) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('trabajadores')
          .where('idArea', isEqualTo: idArea)
          .get();
      List<Trabajador> trabajadores = querySnapshot.docs
          .map((doc) => Trabajador.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return trabajadores;
    } catch (e) {
      print("Error al obtener trabajadores por área $idArea: $e");
      throw Exception('Error al obtener trabajadores por área');
    }
  }
}
