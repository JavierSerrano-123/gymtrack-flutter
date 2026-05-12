class MembershipPlanModel {
  final String? id;
  final String nombre;
  final double precio;
  final int duracionDias; 
  final String? descripcion;

  MembershipPlanModel({
    this.id,
    required this.nombre,
    required this.precio,
    required this.duracionDias,
    this.descripcion,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'precio': precio,
    'duracionDias': duracionDias,
    'descripcion': descripcion,
  };

  factory MembershipPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return MembershipPlanModel(
      id: id,
      nombre: map['nombre'],
      precio: (map['precio'] as num).toDouble(),
      duracionDias: map['duracionDias'],
      descripcion: map['descripcion'],
    );
  }
}
