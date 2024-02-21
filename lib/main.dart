import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicar_movil/firebase_options.dart';
import 'package:servicar_movil/src/controllers/automovil_controller.dart';
import 'package:servicar_movil/src/controllers/cita_controller.dart';
import 'package:servicar_movil/src/controllers/servicio_controller.dart';
import 'package:servicar_movil/src/controllers/usuario_controller.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';
import 'package:servicar_movil/src/widgets/home_screen.dart';
import 'package:servicar_movil/src/widgets/login_form.dart';
import 'package:servicar_movil/src/widgets/register_appointment.dart';
import 'package:servicar_movil/src/widgets/register_car.dart';
import 'package:servicar_movil/src/widgets/register_form.dart';
import 'package:servicar_movil/src/widgets/dashboard_screen.dart';
import 'package:servicar_movil/src/widgets/home_screen.dart';
import 'package:servicar_movil/src/widgets/login_form.dart';
import 'package:servicar_movil/src/widgets/register_appointment.dart';
import 'package:servicar_movil/src/widgets/register_car.dart';
import 'package:servicar_movil/src/widgets/register_form.dart';
import 'package:servicar_movil/src/widgets/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioController()),
        ChangeNotifierProvider(create: (_) => AutomovilController()),
        ChangeNotifierProvider(create: (_) => CitasController()),
        ChangeNotifierProvider(create: (_) => ServicioController()),
      ],
      child: MaterialApp(
          title: 'ServiCar',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white, // Deep purple
              onPrimary: Colors.white, // Text color on primary color backgrounds
              secondary: Color.fromRGBO(219, 219, 219, 1), // Lighter purple
              onSecondary:
                  Colors.white, // Text color on secondary color backgrounds
              background:
                  Color(0xFF212121), // Dark grey for compatible backgrounds
            ),
            useMaterial3: true, // Enable Material 3 features
            scaffoldBackgroundColor: Colors.transparent,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Button background color
                foregroundColor: const Color(0xFF673AB7), // Text color
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                elevation: 5, // Shadow depth
              ),
            ),
            // Additional customizations can be added here
          ),
          home: const SplashScreen(),
          routes: {
            LoginForm.routeName: (context) => const LoginForm(),
            HomeScreen.routeName: (context) => const HomeScreen(),
            RegisterForm.routeName: (context) => const RegisterForm(),
            RegisterCar.routeName: (context) => const RegisterCar(),
            DashboardScreen.routeName: (context) => const DashboardScreen(),
            RegisterAppointment.routeName: (context) =>
                const RegisterAppointment()
          }),
    );
  }
}
