import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/widgets/admin/custom_btttom_naviation_admin.dart';
import 'package:motor_es/widgets/admin/widget_evento_admin.dart';

const Color rojoEvento = Color(0xFFE53935);

class MisEventosCreadosScreen extends StatefulWidget {
  const MisEventosCreadosScreen({super.key});

  @override
  State<MisEventosCreadosScreen> createState() => _MisEventosCreadosScreenState();
}

class _MisEventosCreadosScreenState extends State<MisEventosCreadosScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool mostrarHistorial = false;

  Stream<List<DocumentSnapshot>> obtenerEventosCreadosPorUsuario({
    required bool soloFuturos,
    required bool ordenarPorFechaAsc,
  }) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('eventos')
        .where('creadoPor', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
      List<DocumentSnapshot> eventos = snap.docs;
      final ahora = DateTime.now();

      // Filtrar por futuro o pasado
      eventos = eventos.where((doc) {
        final fecha = (doc['fecha'] as Timestamp).toDate();
        return soloFuturos ? fecha.isAfter(ahora) : fecha.isBefore(ahora);
      }).toList();

      // Ordenar ascendente o descendente
      eventos.sort((a, b) {
        final fechaA = (a['fecha'] as Timestamp).toDate();
        final fechaB = (b['fecha'] as Timestamp).toDate();
        return ordenarPorFechaAsc
            ? fechaA.compareTo(fechaB)
            : fechaB.compareTo(fechaA);
      });

      return eventos;
    });
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Mis eventos creados",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: rojoEvento,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: obtenerEventosCreadosPorUsuario(
                  soloFuturos: true,
                  ordenarPorFechaAsc: true,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final eventos = snapshot.data!;
                  if (eventos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "Aún no has creado ningún evento futuro.",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: eventos.length,
                    itemBuilder: (context, index) {
                      final evento = eventos[index];
                      return EventoCardAdmin(evento: evento);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => setState(() => mostrarHistorial = !mostrarHistorial),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[850],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: rojoEvento),
                    const SizedBox(width: 10),
                    Text(
                      mostrarHistorial
                          ? "Ocultar historial de eventos"
                          : "Ver historial de eventos",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: rojoEvento,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (mostrarHistorial)

                SizedBox(
                  height: 655,
                  child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: obtenerEventosCreadosPorUsuario(
                    soloFuturos: false,
                    ordenarPorFechaAsc: false, 
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final eventosPasados = snapshot.data!;
                    if (eventosPasados.isEmpty) {
                      return const Center(
                        child: Text("No hay eventos pasados aún."),
                      );
                    }

                    return ListView.builder(
                      itemCount: eventosPasados.length,
                      itemBuilder: (context, index) {
                        final evento = eventosPasados[index];
                        return EventoCardAdmin(evento: evento);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationAdmin(),
    );
  }
}
