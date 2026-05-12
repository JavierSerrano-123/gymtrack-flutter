// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/member_model.dart';
import '../../services/member_service.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../routes/app_routes.dart';
import '../members/members_screen.dart';
import '../members/add_member_screen.dart';
import '../payments/payments_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MemberService memberService = MemberService();
  final PaymentService paymentService = PaymentService();
  final NotificationService notificationService = NotificationService();

  List<MemberModel> members = [];
  List<MemberModel> expiredMembers = [];
  bool isLoading = true;
  double totalIncome = 0;

  @override
  void initState() {
    super.initState();
    notificationService.init(); // inicializar notificaciones
    cargarDashboard();
  }

  Future<void> cargarDashboard() async {
    try {
      final allMembers = await memberService.getMembers();
      final expired = await memberService.getExpiredMembers();
      final income = await paymentService.getTotalIncome();

      setState(() {
        members = allMembers;
        expiredMembers = expired;
        totalIncome = income;
        isLoading = false;
      });

      // 🔹 Notificaciones locales
      for (var member in allMembers) {
        final diasRestantes =
            member.fechaVencimiento.difference(DateTime.now()).inDays;

        if (diasRestantes <= 7 && diasRestantes >= 0) {
          notificationService.showNotification(
            "Membresía por vencer",
            "A ${member.nombre} le quedan $diasRestantes días.",
          );
        } else if (diasRestantes < 0) {
          notificationService.showNotification(
            "Membresía vencida",
            "La membresía de ${member.nombre} ya venció.",
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  int get totalMiembros => members.length;
  int get activos => members.where((m) => m.estado == 'Activo').length;
  int get vencidos => expiredMembers.length;

  Color getColorVencidos() {
    if (vencidos == 0) return Colors.green;
    if (vencidos <= 3) return Colors.orange;
    return Colors.red;
  }

  Widget buildCard(String titulo, String valor, IconData icono, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icono, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMemberTile(MemberModel member) {
    final diasRestantes =
        member.fechaVencimiento.difference(DateTime.now()).inDays;

    Color estadoColor;
    if (diasRestantes < 0) {
      estadoColor = Colors.red;
    } else if (diasRestantes <= 7) {
      estadoColor = Colors.orange;
    } else {
      estadoColor = Colors.green;
    }

    return Card(
      child: ListTile(
        leading: Icon(Icons.person, color: estadoColor),
        title: Text(member.nombre),
        subtitle: Text(
          'Vence: ${member.fechaVencimiento.toLocal().toString().split(' ')[0]}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GymTrack Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargarDashboard,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  buildCard(
                    'Total de clientes',
                    totalMiembros.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  buildCard(
                    'Clientes activos',
                    activos.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  buildCard(
                    'Clientes vencidos',
                    vencidos.toString(),
                    Icons.warning,
                    getColorVencidos(),
                  ),
                  buildCard(
                    'Ingreso total',
                    '\$${totalIncome.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.purple,
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Lista de clientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...members.map(buildMemberTile).toList(),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MembersScreen()),
                      ).then((_) => cargarDashboard());
                    },
                    child: const Text('Administrar Miembros'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PaymentsScreen()),
                      ).then((_) => cargarDashboard());
                    },
                    child: const Text('Ver Pagos'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddMemberScreen()),
                      ).then((_) => cargarDashboard());
                    },
                    child: const Text('Agregar Cliente'),
                  ),
                ],
              ),
            ),
    );
  }
}
