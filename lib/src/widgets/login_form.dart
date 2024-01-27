import 'package:flutter/material.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _correo, _password;
  bool _loading = false;
  final UsuarioController _usuarioController = UsuarioController();

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _loading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Aquí va tu lógica de autenticación
      // Ejemplo: await tuMetodoDeAutenticacion(_correo, _password);
      // Por ahora, simulo una demora
      await _usuarioController.autenticarUsuario(_correo, _password);

      // Navegación al dashboard o pantalla principal
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()));

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Ingreso exitoso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Manejo de errores
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error de autenticación: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Altura del contenido del formulario
    const formHeight =
        400.0; // Ajusta este valor según el contenido de tu formulario

    // Espacio superior para centrar el formulario
    final topSpace =
        (screenHeight - appBarHeight - statusBarHeight - formHeight) / 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ingreso'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: topSpace > 0 ? topSpace : 0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/user_image.png',
                      height: 100.0,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email),
                      ),
                      onSaved: (value) => _correo = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Por favor ingrese su correo' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      onSaved: (value) => _password = value!,
                      validator: (value) => value!.isEmpty
                          ? 'Por favor ingrese su contraseña'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity, // Ancho del 100%
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Bordes redondeados
                          ),
                        ),
                        onPressed: _loading ? null : _ingresar,
                        child: const Text('INGRESAR'),
                      ),
                    ),
                    SizedBox(height: topSpace > 0 ? topSpace : 0),
                  ],
                ),
              ),
            ),
            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
