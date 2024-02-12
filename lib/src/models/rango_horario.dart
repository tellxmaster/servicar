import 'package:cloud_firestore/cloud_firestore.dart';

class RangoHorario {
  Timestamp inicio;
  Timestamp fin;

  RangoHorario({required this.inicio, required this.fin});
}
