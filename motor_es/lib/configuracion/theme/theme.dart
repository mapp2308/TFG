// Esta clase define el tema visual de la aplicación.
// Utiliza la clase ThemeData de Flutter para configurar el tema.

import 'package:flutter/material.dart';

class AppTheme {

  // Método que devuelve un objeto ThemeData con la configuración del tema.
  ThemeData getTheme() => ThemeData(
        useMaterial3: true, // Activa el uso de Material 3 para el tema de la aplicación.
        colorSchemeSeed: const Color.fromARGB(255, 255, 217, 0), // Establece un color base para generar la paleta de colores del tema.
        brightness: Brightness.dark, // Define el brillo del tema como oscuro (dark mode).
      );
}