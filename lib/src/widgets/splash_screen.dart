import 'package:flutter/material.dart';
import 'dart:async';

import 'home_screen.dart'; // Import your HomeScreen

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/logo.png'),
              width: 250.0,
              height: 250.0,
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(), // Circular Progress Indicator
          ],
        ),
      ),
    );
  }
}
