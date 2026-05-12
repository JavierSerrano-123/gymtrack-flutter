import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';
import '../../services/member_service.dart';
import '../../services/payment_service.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() =>
      _AddMemberScreenState();
}

class _AddMemberScreenState
    extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  final MemberService memberService = MemberService();
  final PaymentService paymentService = PaymentService();

  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController telefonoController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController montoController =
      TextEditingController();

  bool isLoading = false;

  // Precio base mensual
  final double precioBase = 10.0;

  // Tipo de membresía seleccionado
  String tipoMembresiaSeleccionada = 'Mensual';

  final Map<String, int> tiposMembresia = {
    'Mensual': 1,
    'Trimestral': 3,
    'Semestral': 6,
    'Anual': 12,
  };

  @override
  void initState() {
    super.initState();

    // Por defecto mensual = $10
    montoController.text = precioBase.toStringAsFixed(2);
  }

  void actualizarMontoAutomatico(String tipo) {
    final meses = tiposMembresia[tipo] ?? 1;
    final total = precioBase * meses;

    setState(() {
      tipoMembresiaSeleccionada = tipo;
      montoController.text = total.toStringAsFixed(2);
    });
  }

  Future<void> guardarMiembro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final fechaInicio = DateTime.now();

      final meses =
          tiposMembresia[tipoMembresiaSeleccionada] ?? 1;

      final fechaVencimiento = DateTime(
        fechaInicio.year,
        fechaInicio.month + meses,
        fechaInicio.day,
      );

      final double montoFinal =
          double.parse(montoController.text);

      // CREAR MIEMBRO
      final member = MemberModel(
        nombre: nombreController.text.trim(),
        telefono: telefonoController.text.trim().isEmpty
            ? null
            : telefonoController.text.trim(),
        correo: correoController.text.trim().isEmpty
            ? null
            : correoController.text.trim(),
        fechaInicio: fechaInicio,
        fechaVencimiento: fechaVencimiento,
        estado: 'Activo',
        tipoMembresia: tipoMembresiaSeleccionada,
        montoMensual: montoFinal,
      );

      final String memberId =
          await memberService.addMember(member);

      // CREAR PAGO AUTOMÁTICO
      await paymentService.addPayment(
        PaymentModel(
          memberId: memberId,
          monto: montoFinal,
          fechaPago: DateTime.now(),
          mesPagado:
              "${DateTime.now().month}/${DateTime.now().year}",
          metodoPago: 'Efectivo',
          observaciones:
              'Pago inicial - $tipoMembresiaSeleccionada',
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cliente registrado correctamente',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration deco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Cliente'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: deco('Nombre *'),
                  validator: (v) =>
                      v == null || v.isEmpty
                          ? 'Requerido'
                          : null,
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: tipoMembresiaSeleccionada,
                  decoration: deco('Tipo de membresía'),
                  items: tiposMembresia.keys.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      actualizarMontoAutomatico(value);
                    }
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: montoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: deco(
                    'Total a pagar *',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty
                          ? 'Requerido'
                          : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: telefonoController,
                  decoration:
                      deco('Teléfono (opcional)'),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: correoController,
                  decoration:
                      deco('Correo (opcional)'),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : guardarMiembro,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar Cliente',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}