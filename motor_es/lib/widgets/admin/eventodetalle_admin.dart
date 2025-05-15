import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

const Color rojo = Color(0xFFE53935);

class EventoDetalleAdminWidget extends StatefulWidget {
  final DocumentSnapshot evento;

  const EventoDetalleAdminWidget({super.key, required this.evento});

  @override
  State<EventoDetalleAdminWidget> createState() => _EventoDetalleAdminWidgetState();
}

class _EventoDetalleAdminWidgetState extends State<EventoDetalleAdminWidget> {
  String? nombreAdmin;
  String direccion = 'Cargando...';
  late Future<void> _localeInit;
  int asistentes = 0;
  int favoritos = 0;

  @override
  void initState() {
    super.initState();
    _localeInit = initializeDateFormatting('es_ES', null);
    _loadNombreAdmin();
    _loadDireccion();
    _loadResumenUsuarios();
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

  Future<void> _loadResumenUsuarios() async {
    final asistentesSnap = await FirebaseFirestore.instance
        .collection('user')
        .where('asistir', arrayContains: widget.evento.id)
        .get();

    final favoritosSnap = await FirebaseFirestore.instance
        .collection('user')
        .where('favoritos', arrayContains: widget.evento.id)
        .get();

    setState(() {
      asistentes = asistentesSnap.docs.length;
      favoritos = favoritosSnap.docs.length;
    });
  }

  void _editarEvento(BuildContext context) {
    context.push('/admin/edit', extra: widget.evento);
  }

  void _eliminarEvento(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar evento?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: rojo),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('eventos').doc(widget.evento.id).delete();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evento eliminado exitosamente")),
        );
      }
    }
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

        final String ciudad = data['ciudad'] ?? 'Sin ciudad';
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        nombre,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        maxLines: null,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Editar evento',
                          onPressed: () => _editarEvento(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar evento',
                          onPressed: () => _eliminarEvento(context),
                        ),
                      ],
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
                const SizedBox(height: 12),
                Text(
                  "• $asistentes usuario(s) asistirá(n) \n• $favoritos lo tiene(n) como favorito",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: rojo,
                  ),
                ),
                
                _infoRow(
                  context: context,
                  icon: Icons.description,
                  label: "Descripción",
                  value: descripcion,
                ),
                _infoRow(
                  context: context,
                  icon: Icons.location_city,
                  label: "Ciudad",
                  value: ciudad,
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
