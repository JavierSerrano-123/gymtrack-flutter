class AdminModel {
  final String? id;
  final String nombre;
  final String correo;
  final String rol;

  AdminModel({
    this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'correo': correo,
    'rol': rol,
  };

  factory AdminModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminModel(
      id: id,
      nombre: map['nombre'],
      correo: map['correo'],
      rol: map['rol'],
    );
  }
}
