// lib/screens/payments/payments_screen.dart

import 'package:flutter/material.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService paymentService = PaymentService();

  List<PaymentModel> payments = [];
  bool isLoading = true;
  double totalIncome = 0;

  @override
  void initState() {
    super.initState();
    cargarPagos();
  }

  Future<void> cargarPagos() async {
    try {
      final data = await paymentService.getPayments();
      final income = await paymentService.getTotalIncome();

      setState(() {
        payments = data;
        totalIncome = income;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar pagos: $e'),
        ),
      );
    }
  }

  Future<void> eliminarPago(String id) async {
    try {
      await paymentService.deletePayment(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago eliminado correctamente'),
        ),
      );

      cargarPagos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar pago: $e'),
        ),
      );
    }
  }

  String formatearFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ingresos Totales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalIncome.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: payments.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay pagos registrados',
                          ),
                        )
                      : ListView.builder(
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];

                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  '\$${payment.monto.toStringAsFixed(2)}',
                                ),
                                subtitle: Text(
                                  'Fecha: ${formatearFecha(payment.fechaPago)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                  ),
                                  onPressed: () {
                                    eliminarPago(
                                      payment.id!,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}