import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';

const Color azulMarino = Color(0xFF0D47A1);
const Color moradoOscuro = Color(0xFF3E1C78);
const Color rojoEvento = Color(0xFFE53935);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> cambiarContrasena() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Se ha enviado un enlace para restablecer tu contraseña"),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> eliminarCuenta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Estás seguro?"),
        content: const Text("Esta acción eliminará tu cuenta y todos tus datos asociados."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    final uid = user.uid;

    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).delete();
      await user.delete();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al eliminar la cuenta: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> mostrarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docUser = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
    if (!mounted) return;

    final favoritos = List<String>.from(docUser.data()?['favoritos'] ?? []);
    final asistir = List<String>.from(docUser.data()?['asistir'] ?? []);

    _mostrarModalUsuario(user.email, asistir.length, favoritos.length);
  }

  void _mostrarModalUsuario(String? email, int eventosAsistidos, int eventosFavoritos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            runSpacing: 16,
            children: [
              const Center(
                child: Text(
                  "Tu cuenta",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.email),
                  const SizedBox(width: 10),
                  Expanded(child: Text(email ?? "Correo no disponible")),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.event_available, color: Colors.green),
                  const SizedBox(width: 10),
                  Text("Eventos asistidos: $eventosAsistidos"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 10),
                  Text("Eventos favoritos: $eventosFavoritos"),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: eliminarCuenta,
                icon: const Icon(Icons.delete),
                style: ElevatedButton.styleFrom(backgroundColor: rojoEvento),
                label: const Text("Eliminar cuenta"),
              ),
            ],
          ),
        );
      },
    );
  }

  void mostrarAyudaSubirEvento() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            runSpacing: 16,
            children: const [
              Center(
                child: Text(
                  "¿Cómo subir mi evento?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              Text(
                "Para conseguir el poder subir tu evento escribe un correo a maperaza2005@gmail.com donde se explicará cuánto cuesta la suscripción y cómo funciona la interfaz de administrador. ¡Muchas gracias!",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? moradoOscuro : azulMarino;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajustes",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text("Cambiar contraseña", style: TextStyle(color: Colors.white)),
                onTap: cambiarContrasena,
              ),
              const Divider(color: Colors.white24),

              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text("Cuenta", style: TextStyle(color: Colors.white)),
                onTap: mostrarDatosUsuario,
              ),
              const Divider(color: Colors.white24),

              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.white),
                title: const Text("¿Cómo subir mi evento?", style: TextStyle(color: Colors.white)),
                onTap: mostrarAyudaSubirEvento,
              ),
              const Divider(color: Colors.white24),

              const Spacer(),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rojoEvento,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
                  onPressed: cerrarSesion,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
