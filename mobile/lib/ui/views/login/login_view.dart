import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Logo pequeño superior (es provisional para referenciar el logo original)
            const Icon(Icons.all_inclusive, size: 80, color: AppColors.darkGray),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  // tabs (Registrarse / Iniciar Sesión)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text("Registrarse", style: TextStyle(color: AppColors.mediumGray)),
                      ),
                      const Text("Iniciar Sesión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Bienvenido a Appoyo tu red de apoyo",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  // Formulario
                  _buildTextField("E-mail"),
                  const SizedBox(height: 20),
                  _buildTextField("Contraseña", isPassword: true),
                  const SizedBox(height: 40),
                  // boton iniciar sesion
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.darkGray,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/home'),
                      child: const Text("Iniciar Sesión"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("¿olvidaste tu contraseña?", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }
}