// Task: Pantalla de carga Inicial
import 'package:flutter/material.dart';
import 'dart:async';

import 'home_screen.dart'; // Import your HomeScreen

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    });

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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/logo.png'),
              width: 250.0,
              height: 250.0,
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              color: Colors.white,
            ), // Circular Progress Indicator
          ],
        ),
      ),
    ));
  }
}
