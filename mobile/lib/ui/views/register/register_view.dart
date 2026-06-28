import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  final TextEditingController _userNameController        = TextEditingController();
  final TextEditingController _emailController           = TextEditingController();
  final TextEditingController _passwordController        = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation; // Añadido para un movimiento orgánico de entrada

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  Future<void> _register() async {
    final username        = _userNameController.text;
    final email           = _emailController.text.trim();
    final password        = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    String errorMessage = 'Error al registrarse';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'name': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada con éxito'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        errorMessage = 'Error al registrarse (${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final dynamic rd = jsonDecode(response.body);
            if (rd is Map<String, dynamic>) {
              errorMessage = rd['message'] ?? rd['error'] ?? errorMessage;
            }
          } catch (_) {}
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage), 
              backgroundColor: AppColors.error,
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de colores armónica idéntica al Login remasterizado
    const Color pastelLavenderBg = Color(0xFFF3EFFF); // Fondo Lila Pastel sutil y fresco
    const Color softPurpleAccent = Color(0xFF7C5CFC); // Morado suavizado y estético
    const Color softPurpleHover  = Color(0xFF967CFF);

    return Scaffold(
      backgroundColor: pastelLavenderBg,
      body: SafeArea(
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo Appoyo libre sin encasillar en círculos
                    const _AppoyoLogo(),
                    const SizedBox(height: 12),

                    // Título e Intro con alto contraste sobre el lila pastel
                    const Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1B4B), // Contraste profundo (azul/morado oscuro)
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Únete a la comunidad de Appoyo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B6687), // Texto secundario legible
                        height: 1.4,
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
                            color: const Color(0xFF4A3AFF).withOpacity(0.04),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Nombre de usuario
                          const _InputLabel(label: 'Nombre de usuario'),
                          const SizedBox(height: 8),
                          _SleekTextField(
                            hintText: 'Tu nombre',
                            controller: _userNameController,
                            keyboardType: TextInputType.text,
                            prefixIcon: Icons.person_outline_rounded,
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(height: 20),

                          // Email
                          const _InputLabel(label: 'Correo electrónico'),
                          const SizedBox(height: 8),
                          _SleekTextField(
                            hintText: 'tu@correo.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(height: 20),

                          // Contraseña
                          const _InputLabel(label: 'Contraseña'),
                          const SizedBox(height: 8),
                          _SleekTextField(
                            hintText: '••••••••',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_open_rounded,
                            activeColor: AppColors.primary,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Confirmar contraseña
                          const _InputLabel(label: 'Confirmar contraseña'),
                          const SizedBox(height: 8),
                          _SleekTextField(
                            hintText: '••••••••',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            prefixIcon: Icons.lock_outline_rounded,
                            activeColor: AppColors.primary,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botón Crear Cuenta con tonalidad suavizada y balanceada
                    _PremiumButton(
                      label: 'Crear cuenta',
                      isLoading: _isLoading,
                      activeColor: AppColors.primary,
                      hoverColor: AppColors.primaryMedium,
                      onPressed: _isLoading ? null : _register,
                    ),
                    const SizedBox(height: 32),

                    // Enlace elegante para volver al Login si ya tiene cuenta
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(text: '¿Ya tienes una cuenta? ', style: TextStyle(color: Color(0xFF6B6687))),
                            TextSpan(
                              text: 'Inicia sesión',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Aviso Términos
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B6687),
                            height: 1.6,
                            letterSpacing: 0.1,
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

// ── Logo Libre de Contenedores Rígidos ─────────────────────────────────────────
class _AppoyoLogo extends StatelessWidget {
  const _AppoyoLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Appoyo_logo.png',
      height: 110, // Altura armónica idéntica al Login
      fit: BoxFit.contain,
    );
  }
}

// ── Label de input estilizado ──────────────────────────────────────────────────
class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 2),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1B4B),
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// ── Inputs Modernos Sleek (Sleek Inputs) ───────────────────────────────────────
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
        fillColor: const Color(0xFFFDFDFF),
        prefixIcon: Icon(prefixIcon, color: AppColors.textMuted.withOpacity(0.6), size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        
        // Bordes finos perimetrales de 1px
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

// ── Botón Principal Premium con Respuesta Elástica ─────────────────────────────
class _PremiumButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final Color activeColor;
  final Color hoverColor;
  final VoidCallback? onPressed;

  const _PremiumButton({
    required this.label,
    required this.isLoading,
    required this.activeColor,
    required this.hoverColor,
    this.onPressed,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _pressed
                  ? [widget.activeColor.withOpacity(0.9), widget.hoverColor.withOpacity(0.9)]
                  : [widget.activeColor, widget.hoverColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: widget.activeColor.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}