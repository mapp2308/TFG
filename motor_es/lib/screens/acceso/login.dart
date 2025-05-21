import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/screens/screens.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;

  void toggleForm() {
    setState(() => isLogin = !isLogin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color.fromARGB(255, 70, 66, 66),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    isLogin ? 'Iniciar sesión' : 'Registrarse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();
      final isAdmin = userDoc.data()?['isAdmin'] ?? false;

      if (!mounted) return;
      context.go(isAdmin ? '/admin/home' : '/user/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message ?? 'Error desconocido';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error inesperado: $e';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            labelStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            labelStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: loading ? null : loginUser,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Ingresar',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
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
        TextButton(
          onPressed: widget.onToggle,
          child: const Text(
            '¿No tienes cuenta? Regístrate',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
