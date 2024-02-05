import 'dart:convert';

Trabajador trabajadorFromJson(String str) =>
    Trabajador.fromJson(json.decode(str));

String trabajadorToJson(Trabajador data) => json.encode(data.toJson());

class Trabajador {
  String idTrabajador;
  String nombre;
  String idArea;
  HorasLaborales horasLaborales;

  Trabajador({
    required this.idTrabajador,
    required this.nombre,
    required this.idArea,
    required this.horasLaborales,
  });

  factory Trabajador.fromJson(Map<String, dynamic> json) => Trabajador(
        idTrabajador: json["idTrabajador"],
        nombre: json["nombre"],
        idArea: json["idArea"],
        horasLaborales: HorasLaborales.fromJson(json["horasLaborales"]),
      );

  Map<String, dynamic> toJson() => {
        "idTrabajador": idTrabajador,
        "nombre": nombre,
        "idArea": idArea,
        "horasLaborales": horasLaborales.toJson(),
      };
}

class HorasLaborales {
  String inicio;
  String fin;

  HorasLaborales({
    required this.inicio,
    required this.fin,
  });

  factory HorasLaborales.fromJson(Map<String, dynamic> json) => HorasLaborales(
        inicio: json["inicio"],
        fin: json["fin"],
      );

  Map<String, dynamic> toJson() => {
        "inicio": inicio,
        "fin": fin,
      };
}
