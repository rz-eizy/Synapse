import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Registrarse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Iniciar Sesión", style: TextStyle(color: AppColors.mediumGray)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildTextField("E-mail"),
                  const SizedBox(height: 20),
                  _buildTextField("Contraseña", isPassword: true),
                  const SizedBox(height: 20),
                  _buildTextField("Nombre de usuario"),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.darkGray,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {},
                      child: const Text("Registrarse"),
                    ),
                  ),
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
      ),
    );
  }
}