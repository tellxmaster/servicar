import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:servicar_movil/firebase_options.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';
import 'package:servicar_movil/src/widgets/home_screen.dart';
import 'package:servicar_movil/src/widgets/login_form.dart';
import 'package:servicar_movil/src/widgets/register_car.dart';
import 'package:servicar_movil/src/widgets/register_form.dart';
import 'package:servicar_movil/src/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ServiCar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF673AB7),
            secondary: Color.fromRGBO(124, 77, 255, 1),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          LoginForm.routeName: (context) => const LoginForm(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          RegisterForm.routeName: (context) => const RegisterForm(),
          RegisterCar.routeName: (context) => const RegisterCar(),
          DashboardScreen.routeName: (context) => const DashboardScreen(),
        });
  }
}
