import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_es/configuracion/entities/evento.dart';
import 'package:motor_es/configuracion/entities/useres.dart';

class FirestoreHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Usuarios
  Future<void> addUser(UserModel user) async {
    await _db.collection('user').doc(user.uid.toString()).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('user').doc(user.uid.toString()).update(user.toMap());
  }

  Future<void> deleteUser(int userId) async {
    await _db.collection('user').doc(userId.toString()).delete();
  }

  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('user').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());
  }

  // Eventos
  Future<void> addEvent(EventModel event) async {
    await _db.collection('eventos').add(event.toMap());
  }

  Future<void> updateEvent(String docId, EventModel event) async {
    await _db.collection('eventos').doc(docId).update(event.toMap());
  }

  Future<void> deleteEvent(String docId) async {
    await _db.collection('eventos').doc(docId).delete();
  }

  Stream<List<EventModel>> getAllEvents() {
    return _db.collection('eventos').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromMap(doc.data())).toList());
  }
}
