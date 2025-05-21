import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/widgets/widgets.dart';

class PantallaPrincipal extends ConsumerWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opciones = const [
      {'titulo': 'Mis Eventos', 'imagen': 'assets/Eventos.png'},
      {'titulo': 'Buscar Eventos', 'imagen': 'assets/Buscar.png'},
      {'titulo': 'Cerca de ti', 'imagen': 'assets/Cerca.png'},
      {'titulo': 'Ajustes', 'imagen': 'assets/Ajustes.png'},
    ];

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
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: opciones.map((opcion) {
                      return _OpcionSoloImagen(imagen: opcion['imagen']!, titulo: opcion['titulo']!);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          switch (titulo) {
            case 'Mis Eventos':
              context.go('/user/events');
              break;
            case 'Buscar Eventos':
              context.go('/user/search');
              break;
            case 'Cerca de ti':
              context.go('/user/maps');
              break;
            case 'Ajustes':
              context.go('/user/settings');
              break;
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagen,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
