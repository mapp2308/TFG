import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecoverPasswordWidget extends StatefulWidget {
  const RecoverPasswordWidget({super.key});

  @override
  State<RecoverPasswordWidget> createState() => _RecoverPasswordWidgetState();
}

class _RecoverPasswordWidgetState extends State<RecoverPasswordWidget> {
  final TextEditingController emailController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void mostrarDialogoRecuperacion() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: loading ? null : enviarCorreoRecuperacion,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> enviarCorreoRecuperacion() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe tu correo.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra el AlertDialog

      await Future.delayed(Duration.zero); // Asegura que el contexto esté limpio

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Correo enviado'),
          content: Text(
              'Se ha enviado un enlace de recuperación a:\n\n$email'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      await Future.delayed(Duration.zero);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.message ?? 'Ocurrió un error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: mostrarDialogoRecuperacion,
      child: const Text('¿Olvidaste tu contraseña?'),
    );
  }
}
