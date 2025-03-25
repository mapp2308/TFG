import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String nombre;
  final String descripcion;
  final Timestamp fecha;
  final GeoPoint ubicacion;
  final int creadoPor;
  final String vehiculo;

  EventModel({
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.ubicacion,
    required this.creadoPor,
    required this.vehiculo,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha': fecha,
      'ubicacion': ubicacion,
      'creadoPor': creadoPor,
      'vehiculo': vehiculo,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      fecha: map['fecha'],
      ubicacion: map['ubicacion'],
      creadoPor: map['creadoPor'],
      vehiculo: map['vehiculo'],
    );
  }
}
