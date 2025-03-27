import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/screens/prueb.dart';
import 'package:motor_es/screens/prueba.dart'; // HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  bool isLogin = true;
  String error = '';

  final Color rojo = const Color(0xFFE53935);
  final Color azulMarino = const Color(0xFF0D47A1);

  Future<void> handleAuth() async {
    try {
      UserCredential credential;

      if (isLogin) {
        // Iniciar sesión
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // Registro
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final uid = credential.user!.uid;

        // Por defecto, no es admin
        await FirebaseFirestore.instance.collection('user').doc(uid).set({
          'uid': uid,
          'nombre': nombreController.text.trim(),
          'email': emailController.text.trim(),
          'isAdmin': false,
          'asistir': [],
          'favoritos': [],
        });
      }

      // Verificar si es admin
      final uid = credential.user!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();
print('Datos del usuario: ${userDoc.data()}');
final isAdmin = userDoc.data()?['isAdmin'] ?? false;
print('isAdmin detectado: $isAdmin');


      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePageAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error desconocido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulMarino.withOpacity(0.05),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 64, color: rojo),
                  const SizedBox(height: 16),
                  Text(
                    isLogin ? 'Iniciar sesión' : 'Registrarse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: azulMarino,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!isLogin)
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline, color: azulMarino),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  if (!isLogin) const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined, color: azulMarino),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline, color: azulMarino),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: handleAuth,
                      icon: Icon(isLogin ? Icons.login : Icons.person_add),
                      label: Text(isLogin ? 'Ingresar' : 'Registrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rojo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? '¿No tienes cuenta? Regístrate'
                          : '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: azulMarino),
                    ),
                  ),

                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
