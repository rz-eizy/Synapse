import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/userService.dart';
import '../../../core/services/publicationService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/upgrade_professional_dialog.dart';

class EditAccountView extends StatefulWidget {
  const EditAccountView({super.key});

  @override
  State<EditAccountView> createState() => _EditAccountViewState();
}

class _EditAccountViewState extends State<EditAccountView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();

  final _storage = const FlutterSecureStorage();
  final _userApiService = UserApiService();
  final _pubApiService = PublicationApiService();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _isProfessional = false;

  final _yearsController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _institutionsController = TextEditingController();
  final _contactLinkController = TextEditingController();

  String _selectedRegion = 'Metropolitana';
  String _selectedModality = 'Presencial';

  final List<String> _regions = [
    'Arica y Parinacota', 'Tarapacá', 'Antofagasta', 'Atacama', 'Coquimbo', 'Valparaíso',
    'Metropolitana', 'O\'Higgins', 'Maule', 'Ñuble', 'Biobío', 'La Araucanía',
    'Los Ríos', 'Los Lagos', 'Aysén', 'Magallanes'
  ];

  final List<String> _modalities = ['Presencial', 'Online', 'Híbrido'];

  final List<String> _availableHealthCoverages = ['Fonasa', 'Isapre', 'Dipreca', 'Capredena'];
  final List<String> _selectedHealthCoverages = [];

  final List<String> _availableDiagnostics = [
    'TEA', 'TDAH', 'Dislexia', 'Discalculia', 'Disgrafía', 'Dispraxia',
    'S. de Tourette', 'Tics', 'TEL', 'Tartamudez', 'T. Comunicación Social',
    'Disc. Intelectual', 'Altas Capacidades'
  ];
  final List<String> _selectedDiagnostics = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final token = await _storage.read(key: 'jwt_token') ?? '';
      if (token.isEmpty) return;

      final profileData = await _userApiService.getMyProfile(token);
      if (profileData != null && mounted) {
        setState(() {
          _nameController.text = profileData['username'] ?? '';
          _isProfessional = profileData['role'] == 'professional';
        });

        if (_isProfessional) {
          final proData = await _userApiService.getMyProfessionalProfile(token);
          if (proData != null && mounted) {
            setState(() {
              _yearsController.text = (proData['yearsExperience'] ?? '').toString();
              _priceController.text = (proData['costWork'] ?? '').toString();
              _cityController.text = proData['city'] ?? '';
              _institutionsController.text = proData['institutions'] ?? '';
              
              String loadedLink = proData['externalContactLink'] ?? '';
              if (loadedLink.startsWith('https://wa.me/')) {
                loadedLink = loadedLink.replaceFirst('https://wa.me/', '+');
              } else if (loadedLink.startsWith('https://instagram.com/')) {
                loadedLink = loadedLink.replaceFirst('https://instagram.com/', '@');
              }
              _contactLinkController.text = loadedLink;
              
              if (proData['workRegion'] != null && _regions.contains(proData['workRegion'])) {
                _selectedRegion = proData['workRegion'];
              }
              if (proData['modality'] != null && _modalities.contains(proData['modality'])) {
                _selectedModality = proData['modality'];
              }
              
              if (proData['healthCoverage'] != null) {
                _selectedHealthCoverages.clear();
                _selectedHealthCoverages.addAll(
                  proData['healthCoverage'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
                );
              }
              if (proData['treatedDiagnostics'] != null) {
                _selectedDiagnostics.clear();
                _selectedDiagnostics.addAll(
                  proData['treatedDiagnostics'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
                );
              }
            });
          }
        } else {
          setState(() {
            if (profileData['region'] != null && _regions.contains(profileData['region'])) {
              _selectedRegion = profileData['region'];
            }
            if (profileData['interestedDiagnostics'] != null) {
              _selectedDiagnostics.clear();
              _selectedDiagnostics.addAll(
                profileData['interestedDiagnostics'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
    } finally {
      if (mounted) {
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _fadeController.dispose();
    _yearsController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _businessHoursController.dispose();
    _institutionsController.dispose();
    _contactLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
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
      debugPrint('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    setState(() => _isLoading = true);

    try {
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
            urls['uploadUrl']!,
            _selectedImage!,
            "image/jpeg",
          );
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

      bool success;
      if (_isProfessional) {
        String contact = _contactLinkController.text.trim();
        String finalLink = contact;
        if (contact.isNotEmpty && !contact.startsWith('http')) {
          final isPhone = RegExp(r'^[\+\d\s\-]+$').hasMatch(contact);
          if (isPhone) {
            final number = contact.replaceAll(RegExp(r'\D'), '');
            finalLink = 'https://wa.me/$number';
          } else {
            final username = contact.replaceAll('@', '');
            finalLink = 'https://instagram.com/$username';
          }
        }

        final data = {
          'username': name,
          'profilePicture': finalImageUrl,
          'description': _bioController.text,
          'yearsExperience': int.tryParse(_yearsController.text) ?? 0,
          'institutions': _institutionsController.text,
          'businessHours': _businessHoursController.text,
          'costWork': int.tryParse(_priceController.text) ?? 0,
          'workRegion': _selectedRegion,
          'city': _cityController.text,
          'modality': _selectedModality,
          'healthCoverage': _selectedHealthCoverages.join(', '),
          'treatedDiagnostics': _selectedDiagnostics.join(', '),
          'personalContact': finalLink,
        };
        success = await _userApiService.updateProfessionalProfile(token, data);
      } else {
        success = await _userApiService.updateProfile(
          token,
          name,
          finalImageUrl,
          _selectedRegion,
        );
        if (success) {
          await _userApiService.updateUserPreferences(token, _selectedRegion, _selectedDiagnostics.join(', '));
        }
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Error en el servidor al actualizar');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de advertencia
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              const Text(
                'Eliminar Perfil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Descripción
              const Text(
                '¿Estás seguro que deseas eliminar tu perfil? Esta acción es permanente y no se puede deshacer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Botón Eliminar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sí, eliminar mi perfil'),
                ),
              ),
              const SizedBox(height: 10),

              // Botón Cancelar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final token = await _storage.read(key: 'jwt_token') ?? '';
        if (token.isEmpty) {
            setState(() => _isLoading = false);
            return;
        }

        bool success = await _userApiService.deleteProfile(token);
        if (mounted) {
          if (success) {
            await _storage.delete(key: 'jwt_token');
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al eliminar el perfil')),
            );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF1EEFA)),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header con foto de perfil modularizado e independiente
              _ProfileHeader(
                onEditPhoto: _pickPhoto,
                selectedImage: _selectedImage,
              ),

              // Formulario con scroll
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CustomInputField(
                        label: 'Nombre de usuario',
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre no puede quedar vacío';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),



                      _CustomInputField(
                        label: 'Correo electrónico',
                        controller: _emailController,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!value.contains('@')) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      _CustomInputField(
                        label: 'Biografía',
                        controller: _bioController,
                        icon: Icons.article_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 36),

                      const Text('Ubicación y Preferencias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRegion,
                        decoration: InputDecoration(
                          labelText: 'Región',
                          prefixIcon: const Icon(Icons.map_rounded, color: AppColors.primary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (val) => setState(() => _selectedRegion = val!),
                      ),
                      const SizedBox(height: 32),
                      Text(_isProfessional ? 'Condiciones que atiende' : 'Condiciones de interés', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: _availableDiagnostics.map((diag) {
                          final isSelected = _selectedDiagnostics.contains(diag);
                          return FilterChip(
                            label: Text(diag),
                            selected: isSelected,
                            selectedColor: AppColors.primaryLight,
                            checkmarkColor: AppColors.primary,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedDiagnostics.add(diag);
                                } else {
                                  _selectedDiagnostics.remove(diag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 36),

                      if (_isProfessional) ...[
                        const Text('Información Profesional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 16),
                        _CustomInputField(
                          label: 'Años de experiencia',
                          controller: _yearsController,
                          icon: Icons.access_time_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _CustomInputField(
                          label: 'Precio por sesión (0 si es gratis)',
                          controller: _priceController,
                          icon: Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _CustomInputField(
                          label: 'Ciudad',
                          controller: _cityController,
                          icon: Icons.location_city_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedModality,
                          decoration: InputDecoration(
                            labelText: 'Modalidad de atención',
                            prefixIcon: const Icon(Icons.laptop_chromebook_rounded, color: AppColors.primary, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _modalities.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (val) => setState(() => _selectedModality = val!),
                        ),
                        const SizedBox(height: 16),
                        _CustomInputField(
                          label: 'Institución(es) donde trabajas',
                          controller: _institutionsController,
                          icon: Icons.business_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _CustomInputField(
                          label: 'Horario de atención',
                          controller: _businessHoursController,
                          icon: Icons.schedule_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _CustomInputField(
                          label: 'WhatsApp (número) o Instagram (usuario)',
                          controller: _contactLinkController,
                          icon: Icons.link_rounded,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 32),
                        const Text('Previsiones de Salud', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          children: _availableHealthCoverages.map((cov) {
                            final isSelected = _selectedHealthCoverages.contains(cov);
                            return FilterChip(
                              label: Text(cov),
                              selected: isSelected,
                              selectedColor: AppColors.primaryLight,
                              checkmarkColor: AppColors.primary,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedHealthCoverages.add(cov);
                                  } else {
                                    _selectedHealthCoverages.remove(cov);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 36),
                      ],

                      if (!_isProfessional) ...[
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const UpgradeProfessionalDialog(),
                            );
                          },
                          child: const Text(
                            'Ascender a profesional',
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
                      ],

                      _SubmitButton(
                        isLoading: _isLoading,
                        onPressed: _save,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: TextButton(
                          onPressed: _isLoading ? null : _deleteProfile,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          child: const Text(
                            'Eliminar Perfil',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onEditPhoto;
  final File? selectedImage;

  const _ProfileHeader({
    required this.onEditPhoto,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onEditPhoto,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: selectedImage != null 
                        ? FileImage(selectedImage!) 
                        : null,
                    child: selectedImage == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final String? prefixText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  const _CustomInputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.prefixText,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
            ),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF1EEFA), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF1EEFA), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.isLoading ? null : (_) {
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _pressed || widget.isLoading
                  ? [AppColors.primary.withOpacity(0.85), const Color(0xFF7B2FBE)]
                  : [AppColors.primary, const Color(0xFF8B3FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: _pressed || widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Confirmar Cambios',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}