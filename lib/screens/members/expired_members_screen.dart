// lib/screens/members/expired_members_screen.dart

import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/member_service.dart';

class ExpiredMembersScreen extends StatefulWidget {
  const ExpiredMembersScreen({super.key});

  @override
  State<ExpiredMembersScreen> createState() =>
      _ExpiredMembersScreenState();
}

class _ExpiredMembersScreenState
    extends State<ExpiredMembersScreen> {
  final MemberService memberService = MemberService();

  List<MemberModel> expiredMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarVencidos();
  }

  Future<void> cargarVencidos() async {
    try {
      final data = await memberService.getExpiredMembers();

      setState(() {
        expiredMembers = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar vencidos: $e'),
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
        title: const Text('Membresías Vencidas'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : expiredMembers.isEmpty
              ? const Center(
                  child: Text(
                    'No hay membresías vencidas',
                  ),
                )
              : ListView.builder(
                  itemCount: expiredMembers.length,
                  itemBuilder: (context, index) {
                    final member = expiredMembers[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.warning,
                        ),
                        title: Text(member.nombre),
                        subtitle: Text(
                          'Venció: ${formatearFecha(member.fechaVencimiento)}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}