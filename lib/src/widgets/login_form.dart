import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
import 'package:servicar_movil/src/widgets/admin_screen.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  static const String routeName = '/login';

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  final UsuarioController _usuarioController = UsuarioController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final usuario = await _usuarioController.autenticarUsuario(
        _emailController.text.trim(),
        _passwordController.text,
      );
      _showSnackBar('Ingreso Exitoso', Colors.green);
      _navigateToScreen(usuario.rol);
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  void _navigateToScreen(String role) {
    final routeName =
        role == 'admin' ? AdminScreen.routeName : DashboardScreen.routeName;
    Navigator.of(context).pushNamed(routeName);
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        case 'user-not-found':
        case 'wrong-password':
          return 'Credenciales incorrectas.';
        default:
          return 'Error desconocido. Inténtalo de nuevo más tarde.';
      }
    }
    return 'Error desconocido. Inténtalo de nuevo más tarde.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: Navigator.of(context).pop),
        title: const Text('Ingreso'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/user_image.png', height: 100.0),
                const SizedBox(height: 20),
                _buildTextFormField(_emailController, 'Correo', Icons.email,
                    'Por favor ingrese su correo'),
                const SizedBox(height: 20),
                _buildTextFormField(_passwordController, 'Contraseña',
                    Icons.lock, 'Por favor ingrese su contraseña',
                    isPassword: true),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('INGRESAR'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      IconData icon, String errorMessage,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? errorMessage : null,
    );
  }
}
