import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA), // Fondo unificado limpio de la app
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Logo simple, limpio y escalado correctamente (estilo Login/Register)
                _AppoyoLogo(),
                
                const SizedBox(height: 16),
                
                // Eslogan o texto de apoyo sutil para dar contexto premium
                Text(
                  'Conectando comunidad y apoyo mutuo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withOpacity(0.7),
                    letterSpacing: -0.1,
                  ),
                ),
                
                const SizedBox(height: 80),

                // Botón Iniciar Sesión con gradiente interactivo
                _WelcomeActionButton(
                  label: 'Iniciar Sesión',
                  isPrimary: true,
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
                
                const SizedBox(height: 16),

                // Botón Registrarse con estilo Outlined Premium interactivo
                _WelcomeActionButton(
                  label: 'Registrarse',
                  isPrimary: false,
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget del Logo Simple ───────────────────────────────────────────────────
class _AppoyoLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Appoyo_logo.png',
      width: 220, // Proporción ideal y limpia en pantalla de bienvenida
      fit: BoxFit.contain,
    );
  }
}

// ── Botón de Acción con Feedback Táctil unificado ────────────────────────────
class _WelcomeActionButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _WelcomeActionButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_WelcomeActionButton> createState() => _WelcomeActionButtonState();
}

class _WelcomeActionButtonState extends State<_WelcomeActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: widget.isPrimary
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: _pressed
                        ? [AppColors.primary.withOpacity(0.85), AppColors.primaryMedium]
                        : [AppColors.primary, AppColors.primaryMedium],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26), // Bordes curvos elegantes estilo cápsula
                  boxShadow: _pressed
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                )
              : BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _pressed 
                        ? AppColors.primary.withOpacity(0.5) 
                        : const Color(0xFFF1EEFA), 
                    width: 1.5,
                  ),
                  boxShadow: _pressed
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: widget.isPrimary ? Colors.white : AppColors.primary,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}