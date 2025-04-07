import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/screens/user/eventos_listas/eventos_lista.dart';
import 'package:motor_es/screens/user/eventos_listas/seccion_eventos.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';

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
  String? verTodosTipo;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: verTodosTipo == null
              ? Column(
                  children: [
                    SeccionEventos(
                      titulo: "Eventos que asistirás",
                      icono: Icons.event_available,
                      ids: asistirIds,
                      soloFuturos: true,
                      ordenarPorFechaAsc: true,
                      onVerTodos: () => setState(() => verTodosTipo = "asistir"),
                      streamBuilder: obtenerEventosPorIds,
                    ),
                    const SizedBox(height: 10),
                    SeccionEventos(
                      titulo: "Eventos favoritos",
                      icono: Icons.favorite,
                      ids: favoritosIds,
                      ordenarPorFechaAsc: true,
                      onVerTodos: () => setState(() => verTodosTipo = "favoritos"),
                      streamBuilder: obtenerEventosPorIds,
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => setState(() => verTodosTipo = null),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                verTodosTipo == "favoritos"
                                    ? Icons.favorite
                                    : Icons.event_available,
                                color: rojoEvento,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                verTodosTipo == "favoritos"
                                    ? "Todos los favoritos"
                                    : "Todos los eventos a asistir",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: rojoEvento,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: EventosLista(
                        ids: verTodosTipo == "favoritos"
                            ? favoritosIds
                            : asistirIds,
                        soloFuturos: verTodosTipo == "asistir",
                        ordenarPorFechaAsc: true,
                        streamBuilder: obtenerEventosPorIds,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
