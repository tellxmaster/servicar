// To parse this JSON data, do
//
//     final area = areaFromJson(jsonString);

import 'dart:convert';

Area areaFromJson(String str) => Area.fromJson(json.decode(str));

String areaToJson(Area data) => json.encode(data.toJson());

class Area {
  String idArea;
  String nombre;
  String descripcion;

  Area({
    required this.idArea,
    required this.nombre,
    required this.descripcion,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        idArea: json["idArea"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "idArea": idArea,
        "nombre": nombre,
        "descripcion": descripcion,
      };
}
