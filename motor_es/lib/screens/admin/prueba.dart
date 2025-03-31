import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart'; // ✅ Importar go_router

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              // ✅ Redirige a la pantalla de login usando GoRouter
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Adiós ${user?.email ?? "Mi Loco"}!'),
      ),
      bottomNavigationBar: const CustomBottomNavigation(), // ✅ Añadido aquí
    );
  }
}
