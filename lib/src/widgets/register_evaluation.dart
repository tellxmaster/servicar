import 'package:flutter/material.dart';
import 'package:servicar_movil/src/controllers/evaluacion_controller.dart';
import 'package:servicar_movil/src/models/evaluacion.dart';
import 'package:servicar_movil/src/widgets/info_cita.dart';
import 'package:servicar_movil/src/widgets/transaction_toggle.dart';

class RegisterEvaluation extends StatefulWidget {
   static const String routeName = '/register_evaluation';
   final String? citaId;
  const RegisterEvaluation({super.key, this.citaId});

  @override
  State<RegisterEvaluation> createState() => _RegisterEvaluationState();
}

class _RegisterEvaluationState extends State<RegisterEvaluation> {
  final _formKey = GlobalKey<FormState>();

  // Variables para almacenar las respuestas del usuario
  bool _explicacionDetallada = false;
  bool _recorridoTaller = false;
  final Map<String, int> _calificaciones = {
    'calidadReparo': 1,
    'rapidezReparo': 1,
    'atencionCliente': 1,
    'preciosFacturacion': 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación del Servicio'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    child: Text(
                      '-¿Estás de acuerdo con los siguientes enunciados sobre la entrega de tu vehículo?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildQuestionToggle(
                  '1.- Me explicaron todos los detalles del reparo hecho en el vehículo.',
                     (index) {
                    setState(() {
                      _explicacionDetallada = index == 0; // Si el índice es 0, se seleccionó "Sí"
                    });
                  },
                ),
                _buildQuestionToggle(
                  '2.- El mecánico me llevó a un pequeño recorrido por el taller.',
                    (index) {
                    setState(() {
                      _recorridoTaller = index == 0; // Si el índice es 0, se seleccionó "Sí"
                    });
                  },
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    child: Text(
                      '-¿Cómo evaluarías la calidad de las instalaciones y el servicio brindado?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Card(
                        color: Color.fromARGB(255, 255, 255, 255),
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          child: Text(
                            'Por favor marca: \n1.- El peor, 2.- Bueno, 3.- Regular, 4.- Muy bueno, 5 - Excelente',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                  ),
              ..._buildCalificacionWidgets(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                        elevation: 5, // Shadow depth
                      ),
                  onPressed: () async {
                    Evaluacion nuevaEvaluacion = Evaluacion(
                      idEvaluacion: UniqueKey().toString(), // Generar un ID único para la evaluación si es necesario
                      idCita: widget.citaId!, // Utilizar el ID de la cita pasada al widget
                      explicacionDetallada: _explicacionDetallada,
                      recorridoTaller: _recorridoTaller,
                      calificaciones: _calificaciones,
                    );
                    try {
                      await EvaluacionController().agregarEvaluacion(nuevaEvaluacion);
                      // Si todo sale bien, puedes mostrar un Snackbar o un diálogo informando al usuario que la evaluación se agregó correctamente,
                      // y potencialmente navegar de regreso a la pantalla anterior.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Evaluación agregada con éxito')),
                      );
                      Navigator.of(context)
                       .push(MaterialPageRoute(builder: (context) => InfoCita(id:widget.citaId?? '-' )));
                    } catch (e) {
                      // Si algo sale mal, informa al usuario.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al agregar evaluación: $e')),
                      );
                    }
                  },
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<Widget> _buildCalificacionWidgets() {
    return _calificaciones.keys.map((String key) {
      return ListTile(
        title: Text(_preguntaTexto(key)),
        trailing: DropdownButton<int>(
          value: _calificaciones[key],
          onChanged: (int? newValue) {
            setState(() {
              _calificaciones[key] = newValue!;
            });
          },
          items: <int>[1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
        ),
      );
    }).toList();
  }

  String _preguntaTexto(String clave) {
    switch (clave) {
      case 'calidadReparo':
        return 'La calidad del/los reparo/s';
      case 'rapidezReparo':
        return 'La rapidez del reparo';
      case 'atencionCliente':
        return 'La atención al cliente';
      case 'preciosFacturacion':
        return 'Los precios y facturación';
      default:
        return '';
    }
  }
  Widget _buildQuestionToggle(String question, Function(int index) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(question, style: const TextStyle(fontSize: 16)),
        ),
        TransactionToggle(
          onSelected: onSelected,
        ),
      ],
    );
  }

}