import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/automovil.dart';

class AutomovilController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> agregarAutomovil( String placa, int kilometrajeActual) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    Automovil automovil = Automovil(
      autoId: "",
      uid: uid,
      placa: placa,
      kilometrajeActual: kilometrajeActual,
    );
    // Insertar el objeto en Firestore y obtener la referencia del nuevo documento
    DocumentReference ref =
        await _db.collection('automoviles').add(automovil.toJson());

    // Actualizar el campo autoId del documento con el ID generado automáticamente
    await ref.update({'autoId': ref.id});
  }

  Future<void> actualizarAutomovil(Automovil automovil) async {
    await _db
        .collection('automoviles')
        .doc(automovil.autoId)
        .update(automovil.toJson());
  }

  Future<void> eliminarAutomovil(String autoId) async {
    await _db.collection('automoviles').doc(autoId).delete();
  }

  Future<Automovil> obtenerAutomovil(String autoId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('automoviles').doc(autoId).get();
      if (doc.exists) {
        return Automovil.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Automóvil no encontrado');
      }
    } catch (e) {
      print("Error al obtener automóvil: $e");
      throw Exception('Error al obtener automóvil');
    }
  }

  Future<String> obtenerAutoIdPorUid(String uid) async {
    QuerySnapshot querySnapshot =
        await _db.collection('automoviles').where('uid', isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Asumiendo que solo hay un automóvil por usuario
      DocumentSnapshot doc = querySnapshot.docs.first;
      return doc.id; // Esto es el autoId
    } else {
      throw Exception('Automóvil no encontrado para el uid dado');
    }
  }

  Future<Automovil> obtenerAutoDataPorUid(String uid) async {
    QuerySnapshot querySnapshot =
        await _db.collection('automoviles').where('uid', isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Asumiendo que solo hay un automóvil por usuario
      DocumentSnapshot doc = querySnapshot.docs.first;

      // Imprimir el mapa de datos del documento
      print("DocumentSnapshot Data: ${doc.data()}");

      // Crear el objeto Automovil a partir de los datos del documento
      Automovil auto = Automovil.fromJson(doc.data() as Map<String, dynamic>);

      // Imprimir el objeto Automovil usando el método toString
      print("Automovil: ${auto.toString()}");

      return auto;
    } else {
      throw Exception('Automovil no encontrado para el uid dado');
    }
  }

  Future<String> obtenerModeloPorAutoId(String autoId) async {
    DocumentSnapshot doc =
        await _db.collection('automoviles').doc(autoId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['modelo'] ??
          ''; // Reemplaza 'modelo' con el nombre de campo que estés usando para el modelo del auto
    } else {
      throw Exception('Automóvil no encontrado');
    }
  }

  Stream<Automovil> obtenerAutoDataStream(String uid) {
    return _db
        .collection('automoviles')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        return Automovil.fromJson(
            querySnapshot.docs.first.data());
      } else {
        throw Exception('Automovil no encontrado para el uid dado');
      }
    });
  }
}