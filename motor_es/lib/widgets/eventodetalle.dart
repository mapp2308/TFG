import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class EventoDetalleWidget extends StatefulWidget {
  final DocumentSnapshot evento;

  const EventoDetalleWidget({super.key, required this.evento});

  @override
  State<EventoDetalleWidget> createState() => _EventoDetalleWidgetState();
}

class _EventoDetalleWidgetState extends State<EventoDetalleWidget> {
  String? nombreAdmin;
  String direccion = 'Cargando...';
  late Future<void> _localeInit;

  bool esFavorito = false;
  bool asistira = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _localeInit = initializeDateFormatting('es_ES', null);
    _loadNombreAdmin();
    _loadDireccion();
    _loadEstadosDesdeUsuario(); // Aquí usamos la colección "user"
  }

  Future<void> _loadNombreAdmin() async {
    final creadoPor = widget.evento['creadoPor'];
    final userDoc =
        await FirebaseFirestore.instance.collection('user').doc(creadoPor).get();

    setState(() {
      nombreAdmin = userDoc.data()?['nombreUsuario'] ??
          userDoc.data()?['nombre'] ??
          userDoc.data()?['email'] ??
          'Admin desconocido';
    });
  }

  Future<void> _loadDireccion() async {
    final data = widget.evento.data() as Map<String, dynamic>;
    if (data['ubicacion'] != null && data['ubicacion'] is GeoPoint) {
      final GeoPoint geo = data['ubicacion'];
      try {
        final placemarks =
            await placemarkFromCoordinates(geo.latitude, geo.longitude);
        final placemark = placemarks.first;
        setState(() {
          direccion =
              '${placemark.street?.isNotEmpty == true ? "${placemark.street!}, " : ""}'
              '${placemark.locality ?? ''}, ${placemark.country ?? ''}';
        });
      } catch (e) {
        setState(() {
          direccion = 'No se pudo obtener la dirección';
        });
      }
    } else {
      setState(() {
        direccion = 'Ubicación no especificada';
      });
    }
  }

  Future<void> _loadEstadosDesdeUsuario() async {
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('user').doc(user!.uid);
    final userSnap = await userRef.get();

    final List favoritos = userSnap.data()?['favoritos'] ?? [];
    final List asistir = userSnap.data()?['asistir'] ?? [];

    setState(() {
      esFavorito = favoritos.contains(widget.evento.id);
      asistira = asistir.contains(widget.evento.id);
    });
  }

  Future<void> _toggleFavorito() async {
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('user').doc(user!.uid);
    final idEvento = widget.evento.id;

    await userRef.update({
      'favoritos': esFavorito
          ? FieldValue.arrayRemove([idEvento])
          : FieldValue.arrayUnion([idEvento]),
    });

    setState(() => esFavorito = !esFavorito);
  }

  Future<void> _toggleAsistir() async {
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('user').doc(user!.uid);
    final idEvento = widget.evento.id;

    await userRef.update({
      'asistir': asistira
          ? FieldValue.arrayRemove([idEvento])
          : FieldValue.arrayUnion([idEvento]),
    });

    setState(() => asistira = !asistira);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _localeInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = widget.evento.data() as Map<String, dynamic>;
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final cardColor = theme.cardColor;
        final isDark = theme.brightness == Brightness.dark;

        final String nombre = data['nombre'] ?? 'Evento';
        final String descripcion = data['descripcion'] ?? 'Sin descripción';
        final String tipo = data['tipo'] ?? 'Sin tipo';
        final String vehiculo = data['vehiculo'] ?? 'Sin vehículo';
        final Timestamp fechaRaw = data['fecha'];
        final String fecha =
            DateFormat('dd MMMM yyyy, HH:mm', 'es_ES').format(fechaRaw.toDate());
        final String creador = nombreAdmin ?? 'Cargando...';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['imagenUrl'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      data['imagenUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),

                // Título + botones a la derecha
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        nombre,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        esFavorito ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      tooltip: esFavorito
                          ? 'Quitar de favoritos'
                          : 'Añadir a favoritos',
                      onPressed: _toggleFavorito,
                    ),
                    IconButton(
                      icon: Icon(
                        asistira
                            ? Icons.event_available
                            : Icons.event_available_outlined,
                        color: Colors.green,
                      ),
                      tooltip: asistira
                          ? 'Cancelar asistencia'
                          : 'Marcar asistencia',
                      onPressed: _toggleAsistir,
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 6),
                    Text(
                      fecha,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                Divider(
                    height: 32, thickness: 1.2, color: theme.dividerColor),
                _infoRow(
                  context: context,
                  icon: Icons.description,
                  label: "Descripción",
                  value: descripcion,
                ),
                _infoRow(
                  context: context,
                  icon: Icons.category,
                  label: "Tipo de evento",
                  value: tipo,
                ),
                _infoRow(
                  context: context,
                  icon: Icons.directions_car,
                  label: "Vehículo",
                  value: vehiculo,
                ),
                _infoRow(
                  context: context,
                  icon: Icons.place,
                  label: "Ubicación",
                  value: direccion,
                ),
                _infoRow(
                  context: context,
                  icon: Icons.person,
                  label: "Creado por",
                  value: creador,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
