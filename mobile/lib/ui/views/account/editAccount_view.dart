import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EditAccountView extends StatefulWidget {
  const EditAccountView({super.key});

  @override
  State<EditAccountView> createState() => _EditAccountViewState();
}

class _EditAccountViewState extends State<EditAccountView> {
  bool _isLoading = false;

  // Controladores — Mockeados
  final _nameController        = TextEditingController(text: 'juan pedro pérez');
  final _handleController      = TextEditingController(text: '@jpperez1234');
  final _bioController         = TextEditingController(text:
      'hola amigoss, soy Juan Pedro, pueden llamarme JP, soy padre de un precioso hijo de 7 añitos, llamado Mateo, diagnosticado con Trastorno del espectro autista. 💜');
  final _emailController       = TextEditingController(text: 'jpperez@ejemplo.cl');

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name   = _nameController.text.trim();
    final handle = _handleController.text.trim();
    final bio    = _bioController.text.trim();
    final email  = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y el correo son obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header curvo con avatar --------------
          _ProfileHeader(onEditPhoto: _pickPhoto),

          // Formulario ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(label: 'Nombre',    controller: _nameController),
                  const SizedBox(height: 16),
                  _Field(label: 'Usuario',   controller: _handleController,
                      hint: '@usuario'),
                  const SizedBox(height: 16),
                  _Field(label: 'Biografía', controller: _bioController,
                      maxLines: 4),
                  const SizedBox(height: 16),
                  _Field(label: 'Email',     controller: _emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 28),

                  // Cambiar tipo de cuenta
                  GestureDetector(
                    onTap: () {
                    },
                    child: const Text(
                      'Cambiar a cuenta de profesional',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón Confirmar Cambios ---------------
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
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Confirmar Cambios'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selector de foto próximamente')),
    );
  }
}

// Header curvo con foto de perfil -----------------------
class _ProfileHeader extends StatelessWidget {
  final VoidCallback onEditPhoto;
  const _ProfileHeader({required this.onEditPhoto});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Fondo curvo morado ----------------
        ClipPath(
          clipper: _CurveClipper(),
          child: Container(
            height: 210,
            width: double.infinity,
            color: AppColors.primary,
          ),
        ),

        // AppBar encima del fondo ----------------
        SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Editar perfil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Espacio para equilibrar el back button --------------
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),

        // Avatar centrado, solapado sobre la curva --------------
        Positioned(
          bottom: -44,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.person, size: 52, color: AppColors.primary),
                    ),
                  ),
                  // Botón cámara
                  GestureDetector(
                    onTap: onEditPhoto,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onEditPhoto,
                child: const Text(
                  'Editar Fotografía',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Altura extra para que el avatar no quede cortado ---------------
        const SizedBox(height: 260),
      ],
    );
  }
}

// Clipper para la curva inferior del header ----------------
class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2, size.height + 20,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// Campo de texto reutilizable con label flotante ----------------
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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