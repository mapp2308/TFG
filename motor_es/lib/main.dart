import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motores App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Motores')),
        body: const Center(child: Text('Bienvenido, Mi Loco')),
      ),
    );
  }
}
