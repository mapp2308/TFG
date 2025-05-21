import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motor_es/widgets/widgets.dart';

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

  void mostrarModalCompartir(Map<String, dynamic> data) {
    final fecha = (data['fecha'] as Timestamp?)?.toDate();
    final fechaFormateada =
        fecha != null ? DateFormat('dd/MM/yyyy HH:mm').format(fecha) : 'Sin fecha';
    final mensaje = '''
📍 Evento: ${data['nombre'] ?? ''}
🗓 Fecha: $fechaFormateada
🏙 Ciudad: ${data['ciudad'] ?? ''}

Para encontrar más eventos, descarga MotorEs 🚗🔥
''';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Compartir evento"),
        content: SelectableText(mensaje),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text("Copiar"),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: mensaje));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Texto copiado al portapapeles')),
              );
            },
          ),
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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
        toolbarHeight: 72,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['nombre'] ?? 'Evento',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => mostrarModalCompartir(data),
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text("Compartir", style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFE53935),
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
                color: Color(0xFFE53935),
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
        const Text(
          "Deja tu valoración aquí",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE53935),
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
            backgroundColor: Color(0xFFE53935),
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
              color: Color(0xFFE53935),
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
