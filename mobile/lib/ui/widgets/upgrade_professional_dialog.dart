import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/publicationService.dart';
import '../../core/services/userService.dart';

class UpgradeProfessionalDialog extends StatefulWidget {
  const UpgradeProfessionalDialog({super.key});

  @override
  State<UpgradeProfessionalDialog> createState() => _UpgradeProfessionalDialogState();
}

class _UpgradeProfessionalDialogState extends State<UpgradeProfessionalDialog> {
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final _storage = const FlutterSecureStorage();
  final _pubApiService = PublicationApiService();
  final _userApiService = UserApiService();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error seleccionando imagen: $e');
    }
  }

  Future<void> _submit() async {
    if (_selectedImage == null) return;
    setState(() => _isLoading = true);

    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final urls = await _pubApiService.getUploadURLs(token, "image/jpeg");
      if (urls != null) {
        bool uploaded = await _pubApiService.uploadImageToCloudFlare(
          urls['uploadUrl']!,
          _selectedImage!,
          "image/jpeg",
        );
        if (uploaded) {
          final imageUrl = urls['publicUrl']!;
          String? errorMsg = await _userApiService.requestProfessionalUpgrade(token, imageUrl);
          if (mounted) {
            if (errorMsg == null) {
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitud enviada con éxito'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMsg),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al subir la imagen')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_outlined,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 16),

            const Text(
              'Validación de Título',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Un perfil profesional obtiene una etiqueta destacada, la capacidad de subir imágenes en sus publicaciones y una mayor visibilidad para las empresas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: _selectedImage != null
                      ? Colors.transparent
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedImage != null
                        ? AppColors.primary
                        : AppColors.primaryMedium,
                    width: 1.5,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload_rounded,
                              size: 36, color: AppColors.primary),
                          SizedBox(height: 10),
                          Text(
                            'Subir imagen de carnet\nambos costados',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Toca para seleccionar',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
              ),
            ),

            // Indicador de imagen seleccionada
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    'Imagen seleccionada',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedImage == null || _isLoading) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: AppColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Enviar solicitud'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}