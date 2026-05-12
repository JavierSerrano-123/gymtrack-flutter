// lib/screens/members/members_screen.dart

import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/member_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() =>
      _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {

  final MemberService memberService =
      MemberService();

  List<MemberModel> members = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarMiembros();
  }

  Future<void> cargarMiembros() async {

    try {

      final data =
          await memberService.getMembers();

      setState(() {
        members = data;
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<void> eliminarMiembro(
    String id,
  ) async {

    try {

      await memberService.deleteMember(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Miembro eliminado',
          ),
        ),
      );

      cargarMiembros();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  String formatearFecha(DateTime fecha) {

    return
        "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Miembros'),
        centerTitle: true,
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : members.isEmpty

              ? const Center(
                  child: Text(
                    'No hay miembros registrados',
                  ),
                )

              : ListView.builder(

                  itemCount: members.length,

                  itemBuilder: (context, index) {

                    final member =
                        members[index];

                    final vencido =
                        member.fechaVencimiento
                            .isBefore(
                      DateTime.now(),
                    );

                    return Card(

                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: ListTile(

                        leading: Icon(
                          Icons.person,

                          color: vencido
                              ? Colors.red
                              : Colors.green,
                        ),

                        title:
                            Text(member.nombre),

                        subtitle: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              'Vence: ${formatearFecha(member.fechaVencimiento)}',
                            ),

                            Text(
                              'Monto: \$${member.montoMensual.toStringAsFixed(2)}',
                            ),
                          ],
                        ),

                        trailing: IconButton(

                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          onPressed:
                              () async {

                            final confirmar =
                                await showDialog<bool>(

                              context: context,

                              builder:
                                  (context) {

                                return AlertDialog(

                                  title:
                                      const Text(
                                    'Eliminar miembro',
                                  ),

                                  content:
                                      Text(
                                    '¿Seguro que deseas eliminar a ${member.nombre}?',
                                  ),

                                  actions: [

                                    TextButton(

                                      onPressed:
                                          () {

                                        Navigator.pop(
                                          context,
                                          false,
                                        );
                                      },

                                      child:
                                          const Text(
                                        'Cancelar',
                                      ),
                                    ),

                                    ElevatedButton(

                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red,
                                      ),

                                      onPressed:
                                          () {

                                        Navigator.pop(
                                          context,
                                          true,
                                        );
                                      },

                                      child:
                                          const Text(
                                        'Eliminar',

                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmar ==
                                true) {

                              eliminarMiembro(
                                member.id!,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}