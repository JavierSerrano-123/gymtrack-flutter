class MemberModel {
  final String? id;
  final String nombre;
  final String? telefono;
  final String? correo;
  final DateTime fechaInicio;
  final DateTime fechaVencimiento;
  final String estado;
  final String? tipoMembresia;
  final double montoMensual;
  final String? observaciones; 
  
MemberModel({
  this.id,
  required this.nombre,
  this.telefono,
  this.correo,
  required this.fechaInicio,
  required this.fechaVencimiento,
  required this.estado,
  this.tipoMembresia,
  required this.montoMensual,
  this.observaciones,
});


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'estado': estado,
      'tipoMembresia': tipoMembresia,
      'montoMensual': montoMensual,
      'observaciones': observaciones,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberModel(
      id: id,
      nombre: map['nombre'],
      telefono: map['telefono'],
      correo: map['correo'],
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaVencimiento: DateTime.parse(map['fechaVencimiento']),
      estado: map['estado'],
      tipoMembresia: map['tipoMembresia'],
      montoMensual: (map['montoMensual'] as num).toDouble(),
      observaciones: map['observaciones'],
    );
  }
}
