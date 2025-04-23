import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';

class PantallaPrincipal extends ConsumerWidget {
  const PantallaPrincipal({super.key});

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
                "Bienvenidos",
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
                    children: const [
                      _OpcionInicio(titulo: 'Tus Eventos', imagen: 'assets/Eventos.png'),
                      _OpcionInicio(titulo: 'Buscar Eventos', imagen: 'assets/Buscar.png'),
                      _OpcionInicio(titulo: 'Cerca de ti', imagen: 'assets/Cerca.png'),
                      _OpcionInicio(titulo: 'Ajustes', imagen: 'assets/Ajustes.png'),
                    ],
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

class _OpcionInicio extends StatelessWidget {
  final String titulo;
  final String imagen;

  const _OpcionInicio({
    required this.titulo,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: InkWell(
        onTap: () {
          if (titulo == 'Tus Eventos') {
            context.go('/user/events');
          } else if (titulo == 'Ajustes') {
            context.go('/user/settings');
          } else if (titulo == 'Buscar Eventos') {
            context.go('/user/search');
          } else if (titulo == 'Cerca de ti') {
            context.go('/user/maps');
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagen,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
