import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/userService.dart';
import '../../../core/theme/app_colors.dart';

class ProfessionalOnboardingView extends StatefulWidget {
  const ProfessionalOnboardingView({Key? key}) : super(key: key);

  @override
  _ProfessionalOnboardingViewState createState() =>
      _ProfessionalOnboardingViewState();
}

class _ProfessionalOnboardingViewState
    extends State<ProfessionalOnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final _yearsController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _institutionsController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedRegion = 'Metropolitana';
  String _selectedModality = 'Presencial';

  final List<String> _regions = [
    'Arica y Parinacota', 'Tarapacá', 'Antofagasta', 'Atacama', 'Coquimbo',
    'Valparaíso', 'Metropolitana', 'O\'Higgins', 'Maule', 'Ñuble', 'Biobío',
    'La Araucanía', 'Los Ríos', 'Los Lagos', 'Aysén', 'Magallanes',
  ];
  final List<String> _modalities = ['Presencial', 'Online', 'Híbrido'];

  final List<String> _availableHealthCoverages = [
    'Fonasa', 'Isapre', 'Dipreca', 'Capredena'
  ];
  final List<String> _selectedHealthCoverages = [];

  final List<String> _availableDiagnostics = [
    'TEA', 'TDAH', 'Dislexia', 'Discalculia', 'Disgrafía', 'Dispraxia',
    'S. de Tourette', 'Tics', 'TEL', 'Tartamudez', 'T. Comunicación Social',
    'Disc. Intelectual', 'Altas Capacidades',
  ];
  final List<String> _selectedDiagnostics = [];

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token') ?? '';

    final data = {
      'yearsExperience': int.tryParse(_yearsController.text) ?? 0,
      'institutions': _institutionsController.text,
      'businessHours': _businessHoursController.text,
      'costWork': int.tryParse(_priceController.text) ?? 0,
      'workRegion': _selectedRegion,
      'city': _cityController.text,
      'modality': _selectedModality,
      'professionalDescription': _descriptionController.text,
      'healthCoverage': _selectedHealthCoverages.join(', '),
      'treatedDiagnostics': _selectedDiagnostics.join(', '),
    };

    final apiService = UserApiService();
    final success = await apiService.updateProfessionalProfile(token, data);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al guardar el perfil. Inténtalo de nuevo.')),
      );
    }
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primaryMedium, size: 20)
          : null,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Completar Perfil Profesional',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                  icon: Icons.person_outline, title: 'Información General'),
              const SizedBox(height: 14),

              TextFormField(
                controller: _yearsController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Años de experiencia',
                    icon: Icons.work_outline),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration(
                    'Precio por sesión (0 si es gratis)',
                    icon: Icons.attach_money),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _fieldDecoration(
                    'Breve descripción de lo que haces',
                    icon: Icons.description_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 28),
              _SectionHeader(
                  icon: Icons.location_on_outlined,
                  title: 'Ubicación y Modalidad'),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: _fieldDecoration('Región de trabajo',
                    icon: Icons.map_outlined),
                dropdownColor: Colors.white,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                items: _regions
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedRegion = val!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: _fieldDecoration('Ciudad',
                    icon: Icons.location_city_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedModality,
                decoration: _fieldDecoration('Modalidad de atención',
                    icon: Icons.videocam_outlined),
                dropdownColor: Colors.white,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                items: _modalities
                    .map((m) =>
                        DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedModality = val!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _institutionsController,
                decoration: _fieldDecoration(
                    'Institución(es) donde trabajas',
                    icon: Icons.business_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _businessHoursController,
                decoration: _fieldDecoration(
                    'Horario de atención (ej. Lun–Vie 09:00–18:00)',
                    icon: Icons.schedule_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 28),
              _SectionHeader(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Previsiones de Salud'),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableHealthCoverages.map((cov) {
                  final isSelected =
                      _selectedHealthCoverages.contains(cov);
                  return _AppoyoChip(
                    label: cov,
                    selected: isSelected,
                    onTap: () => setState(() {
                      isSelected
                          ? _selectedHealthCoverages.remove(cov)
                          : _selectedHealthCoverages.add(cov);
                    }),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),
              _SectionHeader(
                  icon: Icons.medical_services_outlined,
                  title: 'Condiciones que atiende'),
              const SizedBox(height: 4),
              const Text(
                'Puedes elegir varias o ninguna por ahora.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableDiagnostics.map((diag) {
                  final isSelected =
                      _selectedDiagnostics.contains(diag);
                  return _AppoyoChip(
                    label: diag,
                    selected: isSelected,
                    onTap: () => setState(() {
                      isSelected
                          ? _selectedDiagnostics.remove(diag)
                          : _selectedDiagnostics.add(diag);
                    }),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Guardar y Continuar'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AppoyoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AppoyoChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                selected ? AppColors.primary : AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}