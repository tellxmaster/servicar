import 'package:flutter/material.dart';
import 'login_form.dart';
import 'register_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bienvenido',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
                    "Es necesario una cuenta para continuar",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF4CAF50), // Button background color
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                        elevation: 5, // Shadow depth
                      ),
                      child: const Text('INGRESAR'),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // Button background color
                        foregroundColor: const Color(0xFF673AB7), // Text color
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                        elevation: 5, // Shadow depth
                      ),
                      child: const Text('REGISTRAR'),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
