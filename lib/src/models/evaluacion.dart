import 'dart:convert';

Evaluacion evaluacionFromJson(String str) => Evaluacion.fromJson(json.decode(str));

String evaluacionToJson(Evaluacion data) => json.encode(data.toJson());

class Evaluacion {
  String idEvaluacion;
  String idCita;
  bool explicacionDetallada;
  bool recorridoTaller;
  Map<String, int> calificaciones;

  Evaluacion({
    required this.idEvaluacion,
    required this.idCita,
    required this.explicacionDetallada,
    required this.recorridoTaller,
    required this.calificaciones,
  });

  factory Evaluacion.fromJson(Map<String, dynamic> json) => Evaluacion(
        idEvaluacion: json["idEvaluacion"],
        idCita: json["idCita"],
        explicacionDetallada: json["explicacionDetallada"],
        recorridoTaller: json["recorridoTaller"],
        calificaciones: Map<String, int>.from(json["calificaciones"]),
      );

  Map<String, dynamic> toJson() => {
        "idEvaluacion": idEvaluacion,
        "idCita": idCita,
        "explicacionDetallada": explicacionDetallada,
        "recorridoTaller": recorridoTaller,
        "calificaciones": calificaciones,
      };
}
