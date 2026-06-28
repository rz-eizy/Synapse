import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _animateIn = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _animateIn = true);
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llene todos los campos'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

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
        if (token.isNotEmpty) {
          await _storage.write(key: 'jwt_token', value: token);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
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
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            behavior: SnackBarBehavior.floating,
          ),
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
    // Definición de colores armónicos para la paleta suave de alta fidelidad
    const Color pastelLavenderBg = Color(0xFFF3EFFF); // Fondo Lila Pastel sutil y fresco
    const Color softPurpleAccent = Color(0xFF7C5CFC); // Morado suavizado, premium y estético
    const Color softPurpleHover = Color(0xFF967CFF);

    return Scaffold(
      backgroundColor: pastelLavenderBg, 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: _animateIn ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                transform: Matrix4.translationValues(0, _animateIn ? 0 : 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo Appoyo libre sin encasillar en círculos
                    const _AppoyoLogo(),
                    const SizedBox(height: 16),

                    // Título e intro con alto contraste sobre el lila pastel
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF1E1B4B), // Contraste profundo (azul/morado oscuro)
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Bienvenido de vuelta a Appoyo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B6687), // Texto secundario legible
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card del Formulario con contraste absoluto (Blanco Puro)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.bgMedium,
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Campo Email
                          _SleekTextField(
                            hintText: 'Correo Electrónico', 
                            controller: _emailController, 
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(height: 20),

                          // Campo Contraseña
                          _SleekTextField(
                            hintText: 'Contraseña', 
                            controller: _passwordController, 
                            obscureText: _obscurePassword, 
                            prefixIcon: Icons.lock_open_rounded,
                            activeColor:AppColors.primary,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword), 
                            ), 
                          ),
                          const SizedBox(height: 16),

                          // Olvidaste tu contraseña estilizado
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {}, 
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botón de acción con tonalidad suavizada y balanceada
                    Container(
                      width: double.infinity, 
                      height: 54, 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: _isLoading ? null : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryMedium],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: _isLoading ? [] : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, 
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white, 
                          elevation: 0, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18), 
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3), 
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading 
                            ? const SizedBox(
                                height: 22, 
                                width: 22, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              ) 
                            : const Text('Ingresar a mi cuenta'), 
                      ), 
                    ),
                    const SizedBox(height: 36),

                    // Aviso Términos
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6687),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// LogoAppoyo libre de contenedores rígidos
class _AppoyoLogo extends StatelessWidget {
  const _AppoyoLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Appoyo_logo.png',
      height: 120, // Altura balanceada para que mantenga un look limpio y no sature
      fit: BoxFit.contain,
    );
  }
}

// Inputs elegantes con adaptabilidad de color de foco
class _SleekTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData prefixIcon;
  final TextEditingController controller; 
  final TextInputType? keyboardType;
  final Color activeColor;

  const _SleekTextField({
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    required this.activeColor,
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
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: const Color(0xFFFDFDFF), // Fondo sutilmente limpio para el input
        prefixIcon: Icon(prefixIcon, color: AppColors.textMuted.withOpacity(0.6), size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        
        // Bordes finos y limpios de alta gama
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: activeColor, width: 1.5),
        ),
      ),
    );
  }
}