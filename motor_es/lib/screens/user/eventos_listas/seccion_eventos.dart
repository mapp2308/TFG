import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/screens/user/eventos_listas/eventos_lista.dart';
const Color rojoEvento = Color(0xFFE53935);

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

  const SeccionEventos({
    super.key,
    required this.titulo,
    required this.icono,
    required this.ids,
    required this.onVerTodos,
    required this.streamBuilder,
    this.soloFuturos = false,
    this.ordenarPorFechaAsc = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                TextButton(
                  onPressed: onVerTodos,
                  child: const Text(
                    "Ver todos",
                    style: TextStyle(
                      color: rojoEvento,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          // Lista de eventos
          Expanded(
            child: EventosLista(
              ids: ids,
              soloFuturos: soloFuturos,
              ordenarPorFechaAsc: ordenarPorFechaAsc,
              streamBuilder: streamBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
