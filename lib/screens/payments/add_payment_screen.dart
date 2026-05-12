

import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';
import '../../services/member_service.dart';
import '../../services/payment_service.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final PaymentService paymentService = PaymentService();
  final MemberService memberService = MemberService();

  List<MemberModel> members = [];
  MemberModel? selectedMember;

  final TextEditingController montoController = TextEditingController();
  final TextEditingController metodoController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarMiembros();
  }

  Future<void> cargarMiembros() async {
    try {
      final data = await memberService.getMembers();
      setState(() {
        members = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar miembros: $e')),
      );
    }
  }

  Future<void> guardarPago() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un miembro')),
      );
      return;
    }

    double monto;
    try {
      monto = double.parse(montoController.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }

    final payment = PaymentModel(
      memberId: selectedMember!.id!,
      monto: monto,
      fechaPago: DateTime.now(),
      mesPagado: "${DateTime.now().month}/${DateTime.now().year}",
      metodoPago: metodoController.text.trim().isEmpty
          ? null
          : metodoController.text.trim(),
      observaciones: null,
    );

    try {
      await paymentService.addPayment(payment);

      // renovar vencimiento automáticamente
      final nuevaFechaVencimiento = DateTime.now().add(const Duration(days: 30));

      final updatedMember = MemberModel(
        id: selectedMember!.id,
        nombre: selectedMember!.nombre,
        telefono: selectedMember!.telefono,
        correo: selectedMember!.correo,
        fechaInicio: selectedMember!.fechaInicio,
        fechaVencimiento: nuevaFechaVencimiento,
        estado: 'Activo',
        tipoMembresia: selectedMember!.tipoMembresia,
        montoMensual: selectedMember!.montoMensual,
        observaciones: selectedMember!.observaciones,
      );

      await memberService.updateMember(selectedMember!.id!, updatedMember);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado correctamente')),
      );

      Navigator.pop(context, true); // 👈 devuelve true para refrescar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar pago: $e')),
      );
    }
  }

  InputDecoration customDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pago'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<MemberModel>(
                      value: selectedMember,
                      decoration: customDecoration('Seleccionar miembro'),
                      items: members.map((member) {
                        return DropdownMenuItem(
                          value: member,
                          child: Text(member.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMember = value;
                          if (value != null) {
                            montoController.text =
                                value.montoMensual.toString();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: montoController,
                      keyboardType: TextInputType.number,
                      decoration: customDecoration('Monto'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El monto es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: metodoController,
                      decoration: customDecoration('Método de pago'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: guardarPago,
                        child: const Text('Guardar Pago'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
