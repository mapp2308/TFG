import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/configuracion/theme/theme.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';

const Color rojoEvento = Color(0xFFE53935);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> cambiarContrasena() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo obtener el correo del usuario."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Se ha enviado un enlace para restablecer tu contraseña."),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al enviar correo: $e"),
        backgroundColor: Colors.red,
      ),
    );
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
        title: const Text("¿Estás seguro?", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        content: const Text("Esta acción eliminará tu cuenta y todos tus datos asociados.", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
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

    try {
      await FirebaseFirestore.instance.collection('user').doc(user.uid).delete();
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

  final eventosFavoritos = favoritos.length;
  final eventosAsistidos = asistir.length;

  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("Tu cuenta",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            ),
            const SizedBox(height: 16),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black26),

            Text("Correo", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text(user.email ?? "Correo no disponible", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 16),

            Text("Eventos asistidos", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text("$eventosAsistidos", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 16),

            Text("Eventos favoritos", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text("$eventosFavoritos", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                onPressed: eliminarCuenta,
                icon: const Icon(Icons.delete, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rojoEvento,
                  foregroundColor: Colors.white,
                ),
                label: const Text("Eliminar cuenta"),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  void mostrarAyudaSubirEvento() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          runSpacing: 16,
          children: [
            Center(
              child: Text(
                "¿Cómo subir mi evento?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black26),
            Text(
              "Para subir tu evento, escribe un correo a maperaza2005@gmail.com donde se te explicará el proceso. ¡Gracias!",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajustes y Ayuda",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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

              

              SwitchListTile(
                title: const Text("Tema oscuro", style: TextStyle(color: Colors.white)),
                secondary: const Icon(Icons.dark_mode, color: Colors.white),
                value: isDarkMode,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
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
