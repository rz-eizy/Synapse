import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                _AppoyoLogo(),
                const SizedBox(height: 16),
                const SizedBox(height: 60),

                // Botón Iniciar Sesión
                _PrimaryButton(
                  label: 'Iniciar Sesión',
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 16),

                // Botón Registrarse
                _OutlinedPurpleButton(
                  label: 'Registrarse',
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppoyoLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Appoyo_logo.png',
      width: 240,
      height: 240,
      fit: BoxFit.contain,
    );
  }
}

// Botón primario reutilizable
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// Botón outlined reutilizable
class _OutlinedPurpleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlinedPurpleButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
