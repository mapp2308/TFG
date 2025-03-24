import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> createUser({
    required int id,
    required String nombre,
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    await _db.collection('users').doc(id.toString()).set({
      'id': id,
      'nombre': nombre,
      'email': email,
      'password': password,
      'isAdmin': isAdmin,
      'favoritos': [],
      'asistir': [],
    });
  }

  static Future<void> createEvento({
    required String nombre,
    required String descripcion,
    required String tipo,
    required DateTime fecha,
    required double latitud,
    required double longitud,
    required int creadoPor,
  }) async {
    await _db.collection('eventos').add({
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'fecha': Timestamp.fromDate(fecha),
      'ubicacion': GeoPoint(latitud, longitud),
      'creadoPor': creadoPor,
    });
  }

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final doc = await _db.collection('users').doc(id.toString()).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<Map<String, dynamic>?> getEventoById(String id) async {
    final doc = await _db.collection('eventos').doc(id).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(id.toString()).update(data);
  }

  static Future<void> updateEvento(String id, Map<String, dynamic> data) async {
    await _db.collection('eventos').doc(id).update(data);
  }
}
