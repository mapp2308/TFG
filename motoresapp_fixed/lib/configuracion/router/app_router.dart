// Este archivo configura las rutas de navegación de la aplicación utilizando GoRouter.
// GoRouter es una librería que facilita la gestión de rutas y navegación en aplicaciones Flutter.

import 'package:go_router/go_router.dart'; // Importa la librería GoRouter para la navegación.



Future<GoRouter> createAppRouter() async {
 

  // Configura el GoRouter
  return GoRouter(
    routes: [
      // Ruta para el login
      GoRoute(
        path: '/login',
      ),

     
    ],
  );
}
