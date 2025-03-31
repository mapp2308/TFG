import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventoCard extends StatelessWidget {
  final DocumentSnapshot evento;

  const EventoCard({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final String nombre = evento['nombre'] ?? 'Sin nombre';
    final String descripcion = evento['descripcion'] ?? '';
    final Timestamp fechaTimestamp = evento['fecha'];
    final DateTime fecha = fechaTimestamp.toDate();

    // Manualmente los meses en español
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    final String dia = fecha.day.toString();
    final String mes = meses[fecha.month - 1];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Fecha (Día grande y mes pequeño)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dia,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  mes.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Información del evento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion.length > 60
                        ? '${descripcion.substring(0, 60)}...'
                        : descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
