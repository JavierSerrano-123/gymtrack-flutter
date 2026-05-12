import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido a GymTrack',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Accede para administrar tus clientes y pagos',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Continuar con Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  await AuthService().signInWithGoogle();
                  // ❌ NO NAVIGATE HERE
                  // Firebase + AuthGate lo hace automático
                },
              ),

              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: () {},
                child: const Text('Ingresar con Email'),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {},
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}