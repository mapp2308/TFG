import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/widgets/widgets.dart';

class EventosLista extends StatelessWidget {
  final List<String> ids;
  final bool soloFuturos;
  final bool ordenarPorFechaAsc;
  final Stream<List<DocumentSnapshot>> Function(
    List<String> ids, {
    bool soloFuturos,
    bool ordenarPorFechaAsc,
  }) streamBuilder;

  final void Function(DocumentSnapshot)? onTapEvento; // 🟢 Nuevo parámetro

  const EventosLista({
    super.key,
    required this.ids,
    required this.streamBuilder,
    this.soloFuturos = false,
    this.ordenarPorFechaAsc = false,
    this.onTapEvento,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: streamBuilder(
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
          itemBuilder: (context, index) {
            final evento = eventos[index];

            return GestureDetector(
              onTap: () => onTapEvento?.call(evento), // 🟢 Ejecuta callback
              child: EventoCard(evento: evento),
            );
          },
        );
      },
    );
  }
}
