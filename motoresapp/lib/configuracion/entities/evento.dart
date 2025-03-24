import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id; // ID del documento en Firestore
  final String nombre;
  final String descripcion;
  final String tipo;
  final DateTime fecha;
  final double latitud;
  final double longitud;
  final int creadoPor;

  Evento({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.fecha,
    required this.latitud,
    required this.longitud,
    required this.creadoPor,
  });

  factory Evento.fromMap(String id, Map<String, dynamic> map) {
    final GeoPoint geo = map['ubicacion'];
    return Evento(
      id: id,
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      tipo: map['tipo'],
      fecha: (map['fecha'] as Timestamp).toDate(),
      latitud: geo.latitude,
      longitud: geo.longitude,
      creadoPor: map['creadoPor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'fecha': Timestamp.fromDate(fecha),
      'ubicacion': GeoPoint(latitud, longitud),
      'creadoPor': creadoPor,
    };
  }
}
