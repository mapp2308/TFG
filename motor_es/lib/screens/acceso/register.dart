import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onToggle;
  const RegisterForm({super.key, required this.onToggle});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  bool loading = false;
  String error = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nombreController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    setState(() {
      loading = true;
      error = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final nombre = nombreController.text.trim();

    if (email.isEmpty || password.isEmpty || nombre.isEmpty) {
      setState(() {
        error = 'Por favor, completa todos los campos.';
        loading = false;
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('user').doc(uid).set({
        'uid': uid,
        'nombre': nombre,
        'email': email,
        'isAdmin': false,
        'asistir': [],
        'favoritos': [],
      });

      if (!mounted) return;
      context.go('/user/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Ocurrió un error durante el registro.';
      });
    } catch (e) {
      setState(() {
        error = 'Error inesperado: $e';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.person_outline, color: Colors.black),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 16),
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
            onPressed: loading ? null : registerUser,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Registrarse', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error, style: const TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: widget.onToggle,
          child: const Text(
            '¿Ya tienes cuenta? Inicia sesión',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
