import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';

class UsuarioController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;

  Future<void> loadUser(String uid) async {
    _currentUser = await obtenerUsuario(uid);
    print("Instance of 'Usuario': ${_currentUser}");
    print("Instance of 'Usuario': ${currentUser}");
    notifyListeners();
  }

  Future<void> registrarUsuario(String email, String password, String nombre,
      String apellido, String cedula, String celular) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    String uid = userCredential.user!.uid;

    Usuario usuario = Usuario(
      uid: uid,
      nombre: nombre,
      apellido: apellido,
      cedula: cedula,
      correo: email,
      celular: celular,
      fechaCreacion: DateTime.now().toIso8601String(),
      ultimaConexion: Timestamp.now(),
    );

    await _db.collection('usuarios').doc(uid).set(usuario.toJson());
  }

  Future<void> autenticarUsuario(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    await _db
        .collection('usuarios')
        .doc(userCredential.user!.uid)
        .update({'ultimaConexion': DateTime.now()});
  }

  Future<void> actualizarUsuario(Usuario usuario) async {
    await _db.collection('usuarios').doc(usuario.uid).update(usuario.toJson());
  }

  Future<void> eliminarUsuario(String uid) async {
    await _db.collection('usuarios').doc(uid).delete();
    User? user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.delete();
    }
  }

  Future<Usuario> obtenerUsuario(String uid) async {
    DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
    if (doc.data() != null) {
      return Usuario.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('Documento no encontrado');
    }
  }

  Future<bool> cerrarSesion(BuildContext context) async {
    try {
      await _auth.signOut();
      return true; // Indica que el cierre de sesión fue exitoso
    } catch (e) {
      return false; // Indica un fallo en el cierre de sesión
    }
  }
}
