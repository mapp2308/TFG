import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/widgets/admin/custom_btttom_naviation_admin.dart';

class PantallaPrincipalAdmin extends ConsumerWidget {
  const PantallaPrincipalAdmin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Parte superior: Añadir Evento
                      _OpcionSoloImagen(
                        imagen: 'assets/Nuevo.png',
                        titulo: 'Añadir Evento',
                      ),
                      const SizedBox(height: 10),

                      // Parte inferior: Mis Eventos y Ajustes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _OpcionSoloImagen(
                            imagen: 'assets/Eventos.png',
                            titulo: 'Mis Eventos',
                          ),
                          const SizedBox(width: 10),
                          _OpcionSoloImagen(
                            imagen: 'assets/Ajustes.png',
                            titulo: 'Ajustes',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationAdmin(),
    );
  }
}

class _OpcionSoloImagen extends StatelessWidget {
  final String imagen;
  final String titulo;

  const _OpcionSoloImagen({
    required this.imagen,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      height: 175,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.all(8),
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey, // Marco sutil
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: () {
            switch (titulo) {
              case 'Mis Eventos':
                context.go('/admin/events');
                break;
              case 'Buscar Eventos':
                context.go('/admin/form');
                break;
              case 'Ajustes':
                context.go('/admin/settings');
                break;
              case 'Añadir Evento':
                context.go('/admin/form');
                break;
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagen,
                fit: BoxFit.cover,
                width: 175,
                height: 175,
                
              ),
            ),
          ),
        ),
      ),
    );
  }
}

