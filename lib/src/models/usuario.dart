import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  String uid;
  String nombre;
  String apellido;
  String cedula;
  String correo;
  String celular;
  String fechaCreacion;
  String ultimaConexion;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.correo,
    required this.celular,
    required this.fechaCreacion,
    required this.ultimaConexion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        uid: json["uid"],
        nombre: json["nombre"],
        apellido: json["apellido"],
        cedula: json["cedula"],
        correo: json["correo"],
        celular: json["celular"],
        fechaCreacion:
            (json["fechaCreacion"] as Timestamp).toDate().toIso8601String(),
        ultimaConexion:
            (json["ultimaConexion"] as Timestamp).toDate().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "nombre": nombre,
        "apellido": apellido,
        "cedula": cedula,
        "correo": correo,
        "celular": celular,
        "fechaCreacion": fechaCreacion,
        "ultimaConexion": ultimaConexion,
      };
}
