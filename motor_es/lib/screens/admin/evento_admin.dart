import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motor_es/widgets/admin/custom_btttom_naviation_admin.dart';
import 'package:motor_es/widgets/admin/eventodetalle_admin.dart';
import 'package:motor_es/widgets/admin/usuario_card.dart';
import 'package:motor_es/widgets/resena_card.dart';

const Color rojo = Color(0xFFE53935);

class DetalleEventoAdminScreen extends StatelessWidget {
  final DocumentSnapshot evento;

  DetalleEventoAdminScreen({super.key, required this.evento});

  final ValueNotifier<String> vistaSeleccionada = ValueNotifier<String>('reseñas');

  Stream<QuerySnapshot> obtenerResenas() {
    return FirebaseFirestore.instance
        .collection('eventos')
        .doc(evento.id)
        .collection('reseñas')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Future<int> obtenerCantidadUsuarios(String campo) async {
    final query = await FirebaseFirestore.instance
        .collection('user')
        .where(campo, arrayContains: evento.id)
        .get();
    return query.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final data = evento.data() as Map<String, dynamic>;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 72,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            data['nombre'] ?? 'Evento',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EventoDetalleAdminWidget(evento: evento),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            ValueListenableBuilder<String>(
              valueListenable: vistaSeleccionada,
              builder: (context, vista, _) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildToggleButton("Reseñas", 'reseñas'),
                        _buildToggleButton("Asistentes", 'asistir'),
                        _buildToggleButton("Favoritos", 'favoritos'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (vista == 'reseñas')
                      _buildListaResenas()
                    else
                      _buildListaUsuarios(tipo: vista),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationAdmin(),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: vistaSeleccionada.value == value ? rojo : Colors.grey[700],
      ),
      onPressed: () {
        vistaSeleccionada.value = value;
      },
      child: Text(label),
    );
  }

  Widget _buildListaResenas() {
    return StreamBuilder<QuerySnapshot>(
      stream: obtenerResenas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final resenas = snapshot.data!.docs;

        if (resenas.isEmpty) {
          return const Text(
            "No hay reseñas todavía",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: rojo,
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: resenas.length,
          itemBuilder: (context, index) {
            final resena = resenas[index];
            final texto = resena['texto'] ?? '';
            final userId = resena['userId'] ?? '';
            final fecha = (resena['fecha'] as Timestamp).toDate();
            final puntuacion = int.tryParse(resena['puntuacion'].toString()) ?? 5;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('user').doc(userId).get(),
              builder: (context, userSnapshot) {
                final nombre = userSnapshot.data?.data() != null
                    ? (userSnapshot.data!.data() as Map<String, dynamic>)['nombreUsuario'] ??
                        (userSnapshot.data!.data() as Map<String, dynamic>)['email'] ??
                        'Usuario'
                    : 'Usuario';

                return ResenaCard(
                  nombreUsuario: nombre,
                  texto: texto,
                  fecha: fecha,
                  puntuacion: puntuacion,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildListaUsuarios({required String tipo}) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('user')
          .where(tipo, arrayContains: evento.id)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final usuarios = snapshot.data!.docs;

        if (usuarios.isEmpty) {
          return Text(
            tipo == 'asistir'
                ? "Nadie ha confirmado asistencia aún"
                : "Nadie ha marcado como favorito este evento",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: rojo,
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final user = usuarios[index].data() as Map<String, dynamic>;
            final nombre = user['nombre'] ?? user['email'] ?? 'Usuario';
            final email = user['email'] ?? '';

            return UsuarioCard(
              nombre: nombre,
              email: email,
            );
          },
        );
      },
    );
  }
}