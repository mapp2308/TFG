import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motor_es/screens/login.dart';
import 'package:motor_es/screens/prueb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MotorEsApp());
}

class MotorEsApp extends StatelessWidget {
  const MotorEsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mientras se carga la autenticación
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si el usuario está logueado, va a HomePage
          if (snapshot.hasData) {
            return const HomePage(); // pantalla principal
          }

          // Si no está logueado, va a LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}
