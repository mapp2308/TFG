import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/screens/user/eventos_listas/eventos_lista.dart';
import 'package:motor_es/screens/user/eventos_listas/seccion_eventos.dart';
import 'package:motor_es/widgets/user/custom_buttom_navigation.dart';
import 'package:motor_es/screens/user/evento.dart';

const Color rojoEvento = Color(0xFFE53935);

class EventosScreen extends StatefulWidget {
  static const String name = 'eventos-screen';
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenScreenState();
}

class _EventosScreenScreenState extends State<EventosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final Stream<DocumentSnapshot> _userStream;
  String? verTodosTipo;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _userStream = _firestore.collection('user').doc(user.uid).snapshots();
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

  Future<void> abrirDetalleEvento(DocumentSnapshot evento) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleEventoScreen(evento: evento),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario logueado')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron datos del usuario')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final favoritosIds = List<String>.from(data['favoritos'] ?? []);
        final asistirIds = List<String>.from(data['asistir'] ?? []);

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
                          onTapEvento: abrirDetalleEvento,
                        ),
                        const SizedBox(height: 10),
                        SeccionEventos(
                          titulo: "Eventos favoritos",
                          icono: Icons.favorite,
                          ids: favoritosIds,
                          ordenarPorFechaAsc: true,
                          onVerTodos: () => setState(() => verTodosTipo = "favoritos"),
                          streamBuilder: obtenerEventosPorIds,
                          onTapEvento: abrirDetalleEvento,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            ids: verTodosTipo == "favoritos" ? favoritosIds : asistirIds,
                            soloFuturos: verTodosTipo == "asistir",
                            ordenarPorFechaAsc: true,
                            streamBuilder: obtenerEventosPorIds,
                            onTapEvento: abrirDetalleEvento,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          bottomNavigationBar: const CustomBottomNavigation(),
        );
      },
    );
  }
}
