import 'dart:convert';

Automovil automovilFromJson(String str) => Automovil.fromJson(json.decode(str));

String automovilToJson(Automovil data) => json.encode(data.toJson());

class Automovil {
  String autoId;
  String uid;
  String placa;
  int kilometrajeActual;

  Automovil({
    required this.autoId,
    required this.uid,
    required this.placa,
    required this.kilometrajeActual,
  });

  factory Automovil.fromJson(Map<String, dynamic> json) => Automovil(
        autoId: json["autoId"],
        uid: json["uid"],
        placa: json["placa"],
        kilometrajeActual: json["kilometrajeActual"],
      );

  Map<String, dynamic> toJson() => {
        "autoId": autoId,
        "uid": uid,
        "placa": placa,
        "kilometrajeActual": kilometrajeActual,
      };
}
