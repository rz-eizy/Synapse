import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/authService.dart';

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
  final _authApiService = AuthApiService();

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

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Recuperar contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa tu correo electrónico y te enviaremos un código de 6 dígitos.', style: TextStyle(color: Color(0xFF6B6687), fontSize: 14)),
              const SizedBox(height: 20),
              _SleekTextField(
                hintText: 'Correo Electrónico',
                controller: emailCtrl,
                prefixIcon: Icons.mail_outline_rounded,
                activeColor: AppColors.primary,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showVerificationCodeDialog(emailCtrl.text); 
                  },
                  child: const Text('Ya tengo un código', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) return;
                setState(() => isLoading = true);
                final success = await _authApiService.requestPasswordReset(email);
                setState(() => isLoading = false);
                if (success && mounted) {
                  Navigator.pop(context);
                  _showVerificationCodeDialog(email);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error enviando código. Verifica tu correo.')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Enviar código'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVerificationCodeDialog(String initialEmail) async {
    final codeCtrl = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Código de Verificación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el código que hemos enviado a tu correo.', style: TextStyle(color: Color(0xFF6B6687), fontSize: 14)),
            const SizedBox(height: 20),
            _SleekTextField(
              hintText: 'Código de 6 dígitos',
              controller: codeCtrl,
              prefixIcon: Icons.lock_outline_rounded,
              activeColor: AppColors.primary,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeCtrl.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/change_password', arguments: {
                  'email': initialEmail,
                  'code': code,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTermsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Términos y Condiciones de Appoyo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1B4B)),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      _AppoyoTerms.content,
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF4A4660), height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                              onTap: _showForgotPasswordDialog, 
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
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6687),
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'Al iniciar sesión estás aceptando nuestros '),
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = _showTermsDialog,
                            ),
                            const TextSpan(text: '.'),
                          ],
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

// Contenido de los Términos y Condiciones de Appoyo
class _AppoyoTerms {
  static const String content = '''
1. Aceptación de los términos
Al utilizar Appoyo aceptas estos Términos y Condiciones y nuestra Política de Privacidad. Si no estás de acuerdo, por favor no utilices la aplicación.

2. Descripción del servicio
Appoyo es una red de apoyo que conecta a tutores de niños, niñas y adolescentes con Trastorno del Espectro Autista (TEA) con otras familias y con profesionales del área, con el fin de compartir experiencias, orientación y contención dentro de una comunidad.

3. Naturaleza del servicio
Appoyo no reemplaza la atención médica, terapéutica ni profesional. La información compartida en la comunidad tiene fines de apoyo y orientación, y no constituye diagnóstico ni tratamiento clínico.

4. Registro y cuentas
Debes proporcionar información veraz al crear tu cuenta. Eres responsable de mantener la confidencialidad de tus credenciales y de la actividad realizada desde tu cuenta.

5. Perfiles de profesionales
Los profesionales que se registran en Appoyo declaran contar con las credenciales y habilitaciones correspondientes. Appoyo puede verificar esta información, pero no garantiza la idoneidad de cada profesional; se recomienda a los usuarios validar credenciales de forma independiente.

6. Uso adecuado de la plataforma
Te comprometes a interactuar con respeto, evitando contenido discriminatorio, ofensivo, engañoso o que vulnere la privacidad de otros usuarios, en especial de niños, niñas y adolescentes.

7. Contenido generado por usuarios
Eres responsable del contenido que publicas (comentarios, publicaciones, reportes). Appoyo puede moderar, ocultar o eliminar contenido que infrinja estos Términos.

8. Privacidad y datos personales
Appoyo trata tus datos personales conforme a la legislación vigente en Chile, incluyendo la Ley N° 21.719. Puedes ejercer tus derechos de acceso, rectificación, cancelación y oposición sobre tus datos.

9. Menores de edad
La aplicación está dirigida a tutores y profesionales adultos. La información sobre menores solo debe ser ingresada por su tutor legal, con fines de coordinación de apoyo.

10. Suspensión de cuentas
Appoyo puede suspender o eliminar cuentas que incumplan estos Términos o que representen un riesgo para la comunidad.

11. Modificaciones
Estos Términos pueden actualizarse periódicamente. Te notificaremos los cambios relevantes dentro de la aplicación.

12. Contacto
Si tienes dudas sobre estos Términos y Condiciones, puedes contactarnos a través de los canales de soporte disponibles en la aplicación.
''';
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