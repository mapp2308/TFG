import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motor_es/widgets/custom_buttom_navigation.dart';
import 'package:motor_es/widgets/eventodetalle.dart';
import 'package:motor_es/widgets/resena_card.dart';

const Color rojo = Color(0xFFE53935);

class DetalleEventoScreen extends StatefulWidget {
  final DocumentSnapshot evento;

  const DetalleEventoScreen({super.key, required this.evento});

  @override
  State<DetalleEventoScreen> createState() => _DetalleEventoScreenState();
}

class _DetalleEventoScreenState extends State<DetalleEventoScreen> {
  final TextEditingController _comentarioController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  int _valoracion = 5;

  Future<void> publicarResena() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty || user == null) return;

    await _firestore
        .collection('eventos')
        .doc(widget.evento.id)
        .collection('reseñas')
        .add({
      'texto': texto,
      'userId': user!.uid,
      'fecha': Timestamp.now(),
      'puntuacion': _valoracion,
    });

    _comentarioController.clear();
    setState(() {
      _valoracion = 5;
    });
  }

  Stream<QuerySnapshot> obtenerResenas() {
    return _firestore
        .collection('eventos')
        .doc(widget.evento.id)
        .collection('reseñas')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.evento.data() as Map<String, dynamic>;
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
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {},
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EventoDetalleWidget(evento: widget.evento),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              "Reseñas",
              style: theme.textTheme.titleLarge?.copyWith(
                color: rojo,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildFormularioComentario(),
            const SizedBox(height: 16),
            _buildListaResenas(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }

  Widget _buildFormularioComentario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Deja tu valoración aquí",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: rojo,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () {
                setState(() {
                  _valoracion = index + 1;
                });
              },
              icon: Icon(
                index < _valoracion ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _comentarioController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: "Escribe tu reseña...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: publicarResena,
          icon: const Icon(Icons.send, color: Colors.white),
          label: const Text("Publicar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: rojo,
            foregroundColor: Colors.white,
          ),
        ),
      ],
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
}
