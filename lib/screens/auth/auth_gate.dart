import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final routes = AppRoutes.routes;

        if (snapshot.hasData) {

          final dashboard = routes[AppRoutes.dashboard];

          if (dashboard != null) {
            return dashboard(context);
          }

          return const Scaffold(
            body: Center(
              child: Text("Dashboard route no existe"),
            ),
          );
        }

        final login = routes[AppRoutes.login];

        if (login != null) {
          return login(context);
        }

        return const Scaffold(
          body: Center(
            child: Text("Login route no existe"),
          ),
        );
      },
    );
  }
}