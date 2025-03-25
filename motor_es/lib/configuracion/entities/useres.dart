class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final bool isAdmin;
  final List<int> asistir;
  final List<int> favoritos;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.isAdmin,
    required this.asistir,
    required this.favoritos,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'isAdmin': isAdmin,
      'asistir': asistir,
      'favoritos': favoritos,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      nombre: map['nombre'],
      email: map['email'],
      isAdmin: map['isAdmin'],
      asistir: List<int>.from(map['asistir']),
      favoritos: List<int>.from(map['favoritos']),
    );
  }
}
