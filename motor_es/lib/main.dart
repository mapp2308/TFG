import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:motor_es/screens/login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MotorEsApp());
}

class MotorEsApp extends StatelessWidget {
  const MotorEsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
