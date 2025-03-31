import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';
import 'package:motor_es/widgets/widget_evento.dart';


const Color azulMarino = Color(0xFF0D47A1);
const Color moradoOscuro = Color(0xFF3E1C78);
const Color rojoEvento = Color(0xFFE53935);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenScreenState();
}

class _HomeScreenScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> favoritosIds = [];
  List<String> asistirIds = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarEventosUsuario();
  }

  Future<void> cargarEventosUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docUser = await _firestore.collection('user').doc(user.uid).get();

    if (docUser.exists) {
      setState(() {
        favoritosIds = List<String>.from(docUser['favoritos'] ?? []);
        asistirIds = List<String>.from(docUser['asistir'] ?? []);
        loading = false;
      });
    }
  }

  Stream<List<DocumentSnapshot>> obtenerEventosPorIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    return _firestore
        .collection('eventos')
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snap) => snap.docs);
  }

  Widget seccionEventos(String titulo, IconData icono, List<String> ids) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icono, color: rojoEvento),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: rojoEvento,
                  ),
                ),
              ],
            ),
          ),
          // Lista con scroll propio
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: obtenerEventosPorIds(ids),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final eventos = snapshot.data ?? [];

                if (eventos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "No hay eventos almacenados aquí, de momento...",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: eventos.length,
                  itemBuilder: (context, index) =>
                      EventoCard(evento: eventos[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? moradoOscuro : azulMarino;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: backgroundColor,
          child: Column(
            children: [
              seccionEventos(
                  "Eventos que asistirás", Icons.event_available, asistirIds),
              const SizedBox(height: 10),
              seccionEventos(
                  "Eventos favoritos", Icons.favorite, favoritosIds),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
