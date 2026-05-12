// lib/models/payment_model.dart

class PaymentModel {

  final String? id;

  final String memberId;


  final String memberName;

  final double monto;

  final DateTime fechaPago;

  final String mesPagado;

  final String? metodoPago;

  final String? observaciones;

  PaymentModel({

    this.id,

    required this.memberId,

   
    required this.memberName,

    required this.monto,

    required this.fechaPago,

    required this.mesPagado,

    this.metodoPago,

    this.observaciones,
  });

  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'memberId': memberId,

      
      'memberName': memberName,

      'monto': monto,

      'fechaPago':
          fechaPago.toIso8601String(),

      'mesPagado': mesPagado,

      'metodoPago': metodoPago,

      'observaciones': observaciones,
    };
  }

  factory PaymentModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {

    return PaymentModel(

      id: id,

      memberId: map['memberId'],

   
      memberName:
          map['memberName'] ?? '',

      monto:
          (map['monto'] as num).toDouble(),

      fechaPago:
          DateTime.parse(
        map['fechaPago'],
      ),

      mesPagado: map['mesPagado'],

      metodoPago: map['metodoPago'],

      observaciones:
          map['observaciones'],
    );
  }
}