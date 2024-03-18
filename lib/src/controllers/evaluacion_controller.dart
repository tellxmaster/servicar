import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servicar_movil/src/models/evaluacion.dart';


class EvaluacionController with  ChangeNotifier{
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   
   Future <void> agregarEvaluacion(Evaluacion evaluacion)async{
    try{
      //Convertir el objeto Evaluacion a Map antes de subirlo
      final evaluacionMap = evaluacion.toJson();

      //Agregar el docuemnto a la colección 'evaluaciones'
      await _firestore.collection('evaluaciones').doc(evaluacion.idEvaluacion).set(evaluacionMap);
      //Opcionalmente, actualizar el documento de la cita para indicar que ya fue evaluada
      await _firestore.collection('citas').doc(evaluacion.idCita).update({
         'evaluada':true,
       });
      print("Evaluación agregada con éxito");
    }catch(e){
      print("Error al agregar evaluación: $e");
      rethrow;
    }
   }
   
}