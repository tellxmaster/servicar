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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF673AB7), // Morado como color primario
              onPrimary: Colors.white, // Texto blanco sobre fondos primarios
              secondary:
                  Color(0xFF9575CD), // Un morado más claro como secundario
              onSecondary:
                  Colors.white, // Texto blanco sobre fondos secundarios
              background: Colors.white, // Blanco para fondos compatibles
              onBackground: Color.fromARGB(
                  255, 46, 46, 46), // Texto negro sobre fondo blanco
              surface: Colors.white, // Blanco para superficies elevadas
              onSurface: Colors.black, // Texto negro sobre superficies blancas
            ),
            useMaterial3: true, // Habilitar características de Material 3
            scaffoldBackgroundColor: Colors.white, // Fondo del scaffold blanco
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF673AB7), // Fondo del AppBar morado
              foregroundColor: Colors.white, // Iconos y texto en AppBar blancos
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xFF673AB7), // Color de fondo de botones morado
                foregroundColor: Colors.white, // Color de texto e íconos blanco
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Esquinas redondeadas
                ),
                elevation: 5, // Profundidad de la sombra
              ),
            ),
            // Aquí puedes añadir personalizaciones adicionales según necesites
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
