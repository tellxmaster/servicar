import 'package:flutter/material.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
//import 'package:servicar_movil/src/widgets/dashboard_screen.dart';
import 'package:servicar_movil/src/widgets/register_car.dart';
//import 'package:servicarmovil_app/views/dashboard_page.dart';

class RegisterForm extends StatefulWidget {
  static const String routeName = '/register';

  const RegisterForm({Key? key}) : super(key: key);

  @override
  RegisterFormState createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UsuarioController _usuarioController = UsuarioController();
  late String _nombre, _apellido, _correo, _cedula, _celular, _password;

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _usuarioController.registrarUsuario(
            _correo.trim(), _password, _nombre, _apellido, _cedula, _celular);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado correctamente'),
            backgroundColor: Color(0xFF28A745),
          ),
        );

        // Reemplaza la pantalla actual con DashboardPage
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegisterCar()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: DefaultTextStyle(
            style: TextStyle(color: Colors.white), // Define tu color aquí
            child: Text('Ocurrió un error'),
          ),
          backgroundColor: Color(0xFFdc3545),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Registrarse'),
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF673AB7), // Start color
              Color.fromRGBO(124, 77, 255, 1), // End color
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                const SizedBox(height: 40.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person),
                        ),
                        onSaved: (value) => _nombre = value!,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor ingrese su nombre'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                          prefixIcon: Icon(Icons.abc),
                        ),
                        onSaved: (value) => _apellido = value!,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor ingrese su apellido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Cédula',
                          prefixIcon: Icon(Icons.person_2_outlined),
                        ),
                        onSaved: (value) => _cedula = value!,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor ingrese su cédula'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Celular',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        onSaved: (value) => _celular = value!,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor ingrese su celular'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          prefixIcon: Icon(Icons.email),
                        ),
                        onSaved: (value) => _correo = value!,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor ingrese su correo'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        onSaved: (value) => _password = value!,
                        validator: (value) => value!.length < 6
                            ? 'La contraseña debe tener al menos 6 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 20.0),
                          ),
                          onPressed: _registrar,
                          child: const Text('REGISTRARSE'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
