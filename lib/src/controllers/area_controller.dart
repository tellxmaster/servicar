import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/area.dart'; // Asegúrate de tener este modelo definido

class AreaController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para obtener todas las áreas
  Future<List<Area>> obtenerAreas() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('areas').get();
      List<Area> areas = querySnapshot.docs
          .map((doc) => Area.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return areas;
    } catch (e) {
      print("Error al obtener áreas: $e");
      throw Exception('Error al obtener áreas');
    }
  }
  Future<Area> obtenerAreaPorId(String idArea) async {
    try {
      DocumentSnapshot doc = await _db.collection('areas').doc(idArea).get();
      if (doc.exists) {
        Area area = Area.fromJson(doc.data() as Map<String, dynamic>);
        return area;
      } else {
        throw Exception('El área no existe');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error al obtener el área: ${e.toString()}');
    }
  }

}
