import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/userService.dart';
import '../../../core/theme/app_colors.dart';

class ProfessionalOnboardingView extends StatefulWidget {
  const ProfessionalOnboardingView({Key? key}) : super(key: key);

  @override
  _ProfessionalOnboardingViewState createState() => _ProfessionalOnboardingViewState();
}

class _ProfessionalOnboardingViewState extends State<ProfessionalOnboardingView> {
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
      'treatedDiagnostics': _selectedDiagnostics.join(', ')
    };

    final apiService = UserApiService();
    final success = await apiService.updateProfessionalProfile(token, data);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el perfil. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Completar Perfil Profesional', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        automaticallyImplyLeading: false, // Prevent back navigation
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Información General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Años de experiencia', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio por sesión (0 si es gratis)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Breve descripción de lo que haces', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              
              const SizedBox(height: 32),
              const Text('Ubicación y Modalidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(labelText: 'Región de trabajo', border: OutlineInputBorder()),
                items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => _selectedRegion = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedModality,
                decoration: const InputDecoration(labelText: 'Modalidad de atención', border: OutlineInputBorder()),
                items: _modalities.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => _selectedModality = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _institutionsController,
                decoration: const InputDecoration(labelText: 'Institución(es) donde trabajas', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessHoursController,
                decoration: const InputDecoration(labelText: 'Horario de atención (ej. Lunes a Viernes de 09:00 a 18:00)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              
              const SizedBox(height: 32),
              const Text('Previsiones de Salud (Aseguradoras)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
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

              const SizedBox(height: 32),
              const Text('Condiciones que atiende', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Text('Puedes elegir varias o ninguna por ahora.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar y Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
