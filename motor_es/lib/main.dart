import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/configuracion/router/app_router.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final router = await createAppRouter();
  runApp(
    ProviderScope(
      child: MyApp(router: router),
    ),
  );
  
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required  this.router});

  // Colores para el tema claro
  static const Color azulMarino = Color(0xFF0D47A1);
  static const Color rojo = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MotorEs',
      themeMode: ThemeMode.system,
      routerConfig: router, // 👈 Se usa el GoRouter aquí

      // Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: azulMarino,
        scaffoldBackgroundColor: azulMarino,
        appBarTheme: const AppBarTheme(backgroundColor: azulMarino, foregroundColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: rojo, foregroundColor: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          prefixIconColor: azulMarino,
        ),
      ),
    );
  }
}
