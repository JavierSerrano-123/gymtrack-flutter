import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/members/members_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/auth/login_screen.dart'; 

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String members = '/members';
  static const String payments = '/payments';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    members: (context) => MembersScreen(),
    payments: (context) => const PaymentsScreen(),
  };
}


