import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';
import 'package:motor_es/widgets/widget_evento.dart';

const Color rojoEvento = Color(0xFFE53935);

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenScreenState();
}

class _EventosScreenScreenState extends State<EventosScreen> {
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

  Stream<List<DocumentSnapshot>> obtenerEventosPorIds(
    List<String> ids, {
    bool soloFuturos = false,
    bool ordenarPorFechaAsc = false,
  }) {
    if (ids.isEmpty) return Stream.value([]);

    return _firestore
        .collection('eventos')
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snap) {
      List<DocumentSnapshot> eventos = snap.docs;

      if (soloFuturos) {
        final ahora = DateTime.now();
        eventos = eventos.where((doc) {
          final fecha = (doc['fecha'] as Timestamp).toDate();
          return fecha.isAfter(ahora);
        }).toList();
      }

      if (ordenarPorFechaAsc) {
        eventos.sort((a, b) {
          final fechaA = (a['fecha'] as Timestamp).toDate();
          final fechaB = (b['fecha'] as Timestamp).toDate();
          return fechaA.compareTo(fechaB);
        });
      }

      return eventos;
    });
  }

  Widget seccionEventos(
    String titulo,
    IconData icono,
    List<String> ids, {
    bool soloFuturos = false,
    bool ordenarPorFechaAsc = false,
  }) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

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
                  style: TextStyle(
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
              stream: obtenerEventosPorIds(
                ids,
                soloFuturos: soloFuturos,
                ordenarPorFechaAsc: ordenarPorFechaAsc,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final eventos = snapshot.data ?? [];

                if (eventos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "No hay eventos almacenados aquí, de momento...",
                        style: TextStyle(fontSize: 16, color: textColor),
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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

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
                "Eventos que asistirás",
                Icons.event_available,
                asistirIds,
                soloFuturos: true,
                ordenarPorFechaAsc: true,
              ),
               const SizedBox(height: 10),
              seccionEventos("Eventos favoritos", Icons.favorite, favoritosIds,ordenarPorFechaAsc: true),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
