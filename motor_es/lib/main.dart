import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Manejo de variables de entorno desde un archivo .env
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Proveedor de estado para la aplicación
import 'package:go_router/go_router.dart';
import 'package:motor_es/configuracion/router/app_router.dart';
import 'package:motor_es/configuracion/theme/theme.dart'; // Manejo de rutas de navegación


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté completamente inicializado antes de continuar

  // Se crea la configuración de rutas usando GoRouter
  final router = await createAppRouter();

  // Carga las variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");

  // Se inicia la aplicación con Riverpod como gestor de estado global
  runApp(
    ProviderScope(
      child: MyApp(router: router),
    ),
  );
}


// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  final GoRouter router; // Instancia de GoRouter para manejar la navegación

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de "Debug" en la aplicación
      title: 'MotorEs', // Nombre de la aplicación
      theme: AppTheme().getTheme(), // Aplica el tema definido en AppTheme
      routerConfig: router, // Se usa GoRouter para manejar la navegación
    );
  }
}
