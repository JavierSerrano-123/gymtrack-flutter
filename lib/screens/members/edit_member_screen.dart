// lib/screens/members/edit_member_screen.dart

import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/member_service.dart';

class EditMemberScreen extends StatefulWidget {
  final MemberModel member;

  const EditMemberScreen({
    super.key,
    required this.member,
  });

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final MemberService memberService = MemberService();

  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  late TextEditingController correoController;
  late TextEditingController montoController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.member.nombre);
    telefonoController = TextEditingController(text: widget.member.telefono ?? '');
    correoController = TextEditingController(text: widget.member.correo ?? '');
    montoController = TextEditingController(text: widget.member.montoMensual.toString());
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    montoController.dispose();
    super.dispose();
  }

  Future<void> actualizarMiembro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    double monto;
    try {
      monto = double.parse(montoController.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      setState(() => isLoading = false);
      return;
    }

    final updatedMember = MemberModel(
      id: widget.member.id,
      nombre: nombreController.text.trim(),
      telefono: telefonoController.text.trim().isEmpty ? null : telefonoController.text.trim(),
      correo: correoController.text.trim().isEmpty ? null : correoController.text.trim(),
      fechaInicio: widget.member.fechaInicio,
      fechaVencimiento: widget.member.fechaVencimiento,
      estado: widget.member.estado,
      tipoMembresia: widget.member.tipoMembresia,
      montoMensual: monto,
      observaciones: widget.member.observaciones,
    );

    try {
      if (widget.member.id == null) {
        throw Exception("El miembro no tiene ID válido");
      }

      await memberService.updateMember(widget.member.id!, updatedMember);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Miembro actualizado correctamente')),
      );

      Navigator.pop(context, true); // 👈 devuelve true para refrescar lista
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
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
        title: const Text('Editar Miembro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: customDecoration('Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefonoController,
                decoration: customDecoration('Teléfono'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: correoController,
                decoration: customDecoration('Correo'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: customDecoration('Monto mensual'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El monto es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : actualizarMiembro,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Actualizar Miembro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
