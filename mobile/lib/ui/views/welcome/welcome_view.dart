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
                // ── Logo ──────────────────────────────────────
                _AppoyoLogo(),
                const SizedBox(height: 16),
                const Text(
                  'APPOYO',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 60),

                // ── Botón Iniciar Sesión ───────────────────────
                _PrimaryButton(
                  label: 'Iniciar Sesión',
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 16),

                // ── Botón Registrarse (outlined) ───────────────
                _OutlinedPurpleButton(
                  label: 'Registrarse',
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),

                // ── DEV: saltar login ──────────────────────────
                // TODO: eliminar antes de producción
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/home'),
                  child: const Text(
                    '[ dev ] entrar sin login',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo decorativo (placeholder del logo real con svg/image) ──────────────
class _AppoyoLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryMedium, width: 2),
        color: AppColors.primaryLight,
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w300,
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
    // TODO: reemplazar con Image.asset('assets/logo_appoyo.png') cuando
    // el logo esté disponible en los assets del proyecto.
  }
}

// ── Botón primario reutilizable ────────────────────────────────────────────
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// ── Botón outlined reutilizable ────────────────────────────────────────────
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}