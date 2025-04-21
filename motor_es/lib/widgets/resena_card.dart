import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResenaCard extends StatelessWidget {
  final String nombreUsuario;
  final String texto;
  final DateTime fecha;
  final int puntuacion;

  const ResenaCard({
    super.key,
    required this.nombreUsuario,
    required this.texto,
    required this.fecha,
    required this.puntuacion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.grey[200];
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del usuario
          Text(
            nombreUsuario,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),

          // Estrellas de puntuación
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < puntuacion ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 6),

          // Texto de la reseña
          Text(
            texto,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),

          // Fecha
          Text(
            DateFormat('dd MMM yyyy – HH:mm', 'es_ES').format(fecha),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
