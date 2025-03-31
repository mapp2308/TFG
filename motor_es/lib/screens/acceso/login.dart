// 📁 login_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motor_es/screens/acceso/recupassword.dart';
import 'package:motor_es/screens/acceso/register.dart';
import 'package:motor_es/screens/admin/prueba.dart';
import 'package:motor_es/screens/user/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  final Color azulMarino = const Color(0xFF0D47A1);

  void toggleForm() {
    setState(() => isLogin = !isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulMarino,
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
                  Icon(Icons.person, size: 64, color: Colors.red),
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
                  isLogin
                      ? LoginForm(onToggle: toggleForm)
                      : RegisterForm(onToggle: toggleForm),
                  const SizedBox(height: 12),
                  if (isLogin) RecoverPasswordWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class LoginForm extends StatefulWidget {
  final VoidCallback onToggle;
  const LoginForm({super.key, required this.onToggle});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String error = '';
  final Color azulMarino = const Color(0xFF0D47A1);

  Future<void> loginUser() async {
    setState(() => loading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();

      final isAdmin = userDoc.data()?['isAdmin'] ?? false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isAdmin ? const HomePageAdmin() : const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: loading ? null : loginUser,
            icon: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.login),
            label: const Text('Ingresar'),
          ),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error, style: const TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: widget.onToggle,
          child: const Text('¿No tienes cuenta? Regístrate'),
        )
      ],
    );
  }
}
