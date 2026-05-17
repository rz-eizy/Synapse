import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Appoyo ---------
                const _AppoyoLogo(),
                const SizedBox(height: 12),

                // Titulo -----------------
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 32.44,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo Email -----------------
                _RoundedTextField(hintText: 'Correo Electrónico'),
                const SizedBox(height: 16),

                // Contraseña -----------------
                _RoundedTextField(
                  hintText: 'Contraseña',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 28),

                // Iniciar Sesión ----------
                SizedBox(
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
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                    child: const Text('Iniciar Sesión'),
                  ),
                ),
                const SizedBox(height: 20),

                // Olvidaste tu contraseña ----------------
                GestureDetector(
                  onTap: () {}, // (redirección pendiente)
                  child: const Text(
                    'Olvidaste tu Contraseña?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Aviso Terminos -----------------------
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Al completar el proceso de creación de cuenta estarás aceptando nuestros ',
                      ),
                      TextSpan(
                        text: 'Términos y Condiciones.',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

// LogoAppoyo -----------
class _AppoyoLogo extends StatelessWidget {
  const _AppoyoLogo();

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

// Campo de texto redondeado -----------
class _RoundedTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;

  const _RoundedTextField({
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
