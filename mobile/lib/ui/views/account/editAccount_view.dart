import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/userService.dart';
import '../../../core/services/publicationService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditAccountView extends StatefulWidget {
  const EditAccountView({super.key});

  @override
  State<EditAccountView> createState() => _EditAccountViewState();
}

class _EditAccountViewState extends State<EditAccountView> {
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  final _nameController        = TextEditingController();
  final _handleController      = TextEditingController();
  final _bioController         = TextEditingController();
  final _emailController       = TextEditingController();

  final _storage = const FlutterSecureStorage();
  final _userApiService = UserApiService();
  final _pubApiService = PublicationApiService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final token = await _storage.read(key: 'jwt_token') ?? '';
    if (token.isEmpty) return;

    final profileData = await _userApiService.getMyProfile(token);
    if (profileData != null && mounted) {
      setState(() {
        _nameController.text = profileData['username'] ?? '';
        _handleController.text = profileData['username'] ?? ''; // bio y email se quedan vacíos por ahora porque el DTO no los soporta.
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _save() async {
    final handle = _handleController.text.trim();

    if (handle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El usuario es obligatorio')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final token = await _storage.read(key: 'jwt_token') ?? '';
    if (token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    String? finalImageUrl;
    if (_selectedImage != null) {
      final urls = await _pubApiService.getUploadURLs(token, "image/jpeg");
      if (urls != null) {
        bool uploaded = await _pubApiService.uploadImageToCloudFlare(
            urls['uploadUrl']!, _selectedImage!, "image/jpeg");
        if (uploaded) {
          finalImageUrl = urls['publicUrl'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen a la nube')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }
    }

    bool success = await _userApiService.updateProfile(
      token, 
      handle, 
      finalImageUrl, 
      "Araucanía"
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el perfil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header curvo con avatar --------------
          _ProfileHeader(
            onEditPhoto: () => _pickPhoto(),
            selectedImage: _selectedImage,
          ),

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
}

// Header curvo con foto de perfil -----------------------
class _ProfileHeader extends StatelessWidget {
  final VoidCallback onEditPhoto;
  final File? selectedImage;
  const _ProfileHeader({required this.onEditPhoto, this.selectedImage});

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
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                      child: selectedImage == null ? const Icon(Icons.person, size: 52, color: AppColors.primary) : null,
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