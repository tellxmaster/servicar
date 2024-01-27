import 'package:flutter/material.dart';
import 'login_form.dart';
import 'register_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bienvenido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/logo.png', width: 275.0, // Ancho de 100px
              height: 275.0,
            ), // Asegúrate de tener la imagen en tus assets
            const SizedBox(height: 20),
            Column(
              children: <Widget>[
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child: Text(
                    "Necesitas una cuenta para continuar",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  child: SizedBox(
                    width: double
                        .infinity, // Esto hace que el botón sea tan ancho como sea posible
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const LoginForm())),
                      child: const Text('Ingresar'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  child: SizedBox(
                    width: double
                        .infinity, // Esto hace que el botón sea tan ancho como sea posible
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const RegisterForm())),
                      child: const Text('Registrar'),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
