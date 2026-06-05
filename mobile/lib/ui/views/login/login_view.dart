import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Llene los campos')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'] ?? '';
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        String errorMessage = 'Error al iniciar sesión (${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final dynamic responseData = jsonDecode(response.body);
            if (responseData is Map<String, dynamic>) {
              errorMessage = responseData['message'] ??
                  responseData['error'] ??
                  errorMessage;
            }
          } catch (_) {}
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent,),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                _RoundedTextField(hintText: 'Correo Electrónico', controller: _emailController, keyboardType: TextInputType.emailAddress,),
                const SizedBox(height: 16),

                // Contraseña -----------------
                _RoundedTextField(hintText: 'Contraseña', controller: _passwordController, obscureText: _obscurePassword, suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted,),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword), ), ),
                const SizedBox(height: 28),

                // Iniciar Sesión ----------
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, ), ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2,), ) : const Text('Iniciar Sesión'), ), ),
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
  final TextEditingController controller; // Required
  final TextInputType? keyboardType;

  const _RoundedTextField({
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
