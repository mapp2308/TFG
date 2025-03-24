class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String password;
  final bool isAdmin;
  final List<int> favoritos;
  final List<int> asistir;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.isAdmin,
    required this.favoritos,
    required this.asistir,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      password: map['password'],
      isAdmin: map['isAdmin'] ?? false,
      favoritos: List<int>.from(map['favoritos'] ?? []),
      asistir: List<int>.from(map['asistir'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'password': password,
      'isAdmin': isAdmin,
      'favoritos': favoritos,
      'asistir': asistir,
    };
  }
}
