import 'dart:convert';

Cita citaFromJson(String str) => Cita.fromJson(json.decode(str));

String citaToJson(Cita data) => json.encode(data.toJson());

class Cita {
  String idCita;
  String idCliente;
  String idServicio;
  String idTrabajador;
  String fechaHoraInicio;
  String fechaHoraFin;
  String estado;

  Cita({
    required this.idCita,
    required this.idCliente,
    required this.idServicio,
    required this.idTrabajador,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
        idCita: json["idCita"],
        idCliente: json["idCliente"],
        idServicio: json["idServicio"],
        idTrabajador: json["idTrabajador"],
        fechaHoraInicio: json["fechaHoraInicio"],
        fechaHoraFin: json["fechaHoraFin"],
        estado: json["estado"],
      );

  Map<String, dynamic> toJson() => {
        "idCita": idCita,
        "idCliente": idCliente,
        "idServicio": idServicio,
        "idTrabajador": idTrabajador,
        "fechaHoraInicio": fechaHoraInicio,
        "fechaHoraFin": fechaHoraFin,
        "estado": estado,
      };
}
