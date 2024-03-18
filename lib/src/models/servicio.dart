import 'dart:convert';

Servicio servicioFromJson(String str) => Servicio.fromJson(json.decode(str));

String servicioToJson(Servicio data) => json.encode(data.toJson());

class Servicio {
  String idServicio;
  String nombre;
  String duracion;
  String idArea;

  Servicio({
    required this.idServicio,
    required this.nombre,
    required this.duracion,
    required this.idArea,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) => Servicio(
        idServicio: json["idServicio"],
        nombre: json["nombre"],
        duracion: json["duracion"],
        idArea: json["idArea"],
      );

  Map<String, dynamic> toJson() => {
        "idServicio": idServicio,
        "nombre": nombre,
        "duracion": duracion,
        "idArea": idArea,
      };
}
