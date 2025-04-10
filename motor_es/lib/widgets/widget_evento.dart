import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/screens/user/eveto.dart';

class EventoCard extends StatelessWidget {
  final DocumentSnapshot evento;

  const EventoCard({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final String nombre = evento['nombre'] ?? 'Sin nombre';
    final String descripcion = evento['descripcion'] ?? '';
    final Timestamp fechaTimestamp = evento['fecha'];
    final DateTime fecha = fechaTimestamp.toDate();

    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    final String dia = fecha.day.toString();
    final String mes = meses[fecha.month - 1];

    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final subtleColor = Theme.of(context).textTheme.bodySmall?.color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleEventoScreen(evento: evento),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Fecha
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dia,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    mes.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: subtleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Info evento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion.length > 60
                          ? '${descripcion.substring(0, 60)}...'
                          : descripcion,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
