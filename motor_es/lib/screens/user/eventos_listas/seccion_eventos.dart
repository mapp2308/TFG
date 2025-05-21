import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/screens/screens.dart';


class SeccionEventos extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<String> ids;
  final bool soloFuturos;
  final bool ordenarPorFechaAsc;
  final VoidCallback onVerTodos;
  final Stream<List<DocumentSnapshot>> Function(
    List<String> ids, {
    bool soloFuturos,
    bool ordenarPorFechaAsc,
  }) streamBuilder;

  final void Function(DocumentSnapshot)? onTapEvento; // 🟢 Nuevo parámetro

  const SeccionEventos({
    super.key,
    required this.titulo,
    required this.icono,
    required this.ids,
    required this.onVerTodos,
    required this.streamBuilder,
    this.soloFuturos = false,
    this.ordenarPorFechaAsc = false,
    this.onTapEvento,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icono, color: Color(0xFFE53935)),
                    const SizedBox(width: 8),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onVerTodos,
                  child: const Text(
                    "Ver todos",
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: EventosLista(
              ids: ids,
              soloFuturos: soloFuturos,
              ordenarPorFechaAsc: ordenarPorFechaAsc,
              streamBuilder: streamBuilder,
              onTapEvento: onTapEvento, // 🟢 Pasamos callback
            ),
          ),
        ],
      ),
    );
  }
}
