import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';
import 'package:motor_es/widgets/eventodetalle.dart';

const Color rojo = Color(0xFFE53935);

class DetalleEventoScreen extends StatelessWidget {
  final DocumentSnapshot evento;

  const DetalleEventoScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final data = evento.data() as Map<String, dynamic>;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            data['nombre'] ?? 'Evento',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Forzado para coherencia visual como en EventFilterScreen
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                // Aquí podrías agregar acción como "Compartir evento"
              },
              icon: const Icon(Icons.share, color: Colors.white),
              
              label: const Text("Compartir", style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: rojo,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: EventoDetalleWidget(evento: evento),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
