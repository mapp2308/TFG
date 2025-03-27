import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:motor_es/screens/acceso/login.dart'; // o donde esté tu LoginPage


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Colores para el tema claro
  static const Color azulMarino = Color(0xFF0D47A1);
  static const Color rojo = Color(0xFFE53935);

  // Colores para el tema oscuro
  static const Color morado = Color(0xFF6A1B9A);
  static const Color vinotinto = Color(0xFF8E2430);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotorEs',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Usa claro/oscuro según el sistema
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: azulMarino,
        scaffoldBackgroundColor: azulMarino.withOpacity(0.05),
        appBarTheme: const AppBarTheme(backgroundColor: azulMarino, foregroundColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: rojo, foregroundColor: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          prefixIconColor: azulMarino,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: morado,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: morado, foregroundColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: vinotinto, foregroundColor: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          prefixIconColor: morado,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
