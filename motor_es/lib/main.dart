import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/configuracion/router/app_router.dart';
import 'package:motor_es/configuracion/theme/theme.dart';


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

class MyApp extends ConsumerWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  static const Color azulMarino = Color(0xFF0D47A1);
  static const Color rojo = Color(0xFFE53935);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MotorEs',
      themeMode: themeMode,
      routerConfig: router,

      // 🌞 TEMA CLARO
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: azulMarino,
        scaffoldBackgroundColor: azulMarino,
        appBarTheme: const AppBarTheme(
          backgroundColor: azulMarino,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        dividerColor: Colors.white24,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: rojo, foregroundColor: Colors.white),
        ),
      ),

      // 🌚 TEMA OSCURO
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[850],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        dividerColor: Colors.white24,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: rojo),
        ),
      ),
    );
  }
}
