import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/professionalService.dart';

// Modelo de datos para un profesional
class _Professional {
  final String id;
  final String name;
  final String handle;
  final String imageUrl;
  final double rating;
  final String experience;
  final String institution;
  final List<String> modalities;
  final String city;
  final String businessHours;
  final String description;

  const _Professional({
    required this.id,
    required this.name,
    required this.handle,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.institution,
    this.modalities = const [],
    this.city = '',
    this.businessHours = '',
    this.description = '',
  });

  factory _Professional.fromJson(Map<String, dynamic> json) {
    int years = json['yearsExperience'] ?? 0;
    String mod = json['modality'] ?? '';
    List<String> parsedModalities = mod.isNotEmpty 
        ? mod.split(',').map((e) => e.trim()).toList()
        : [];
    
    return _Professional(
      id: json['professionalId'] ?? '',
      name: json['username'] ?? 'Desconocido',
      handle: '@${json['professionName'] ?? 'Profesional'}',
      imageUrl: json['profilePictureUrl'] ?? '',
      rating: (json['averageStars'] ?? 0.0).toDouble(),
      experience: years > 0 ? '$years años de experiencia' : 'Sin experiencia registrada',
      institution: json['institutions'] ?? 'Institución no especificada',
      modalities: parsedModalities,
      city: json['city'] ?? '',
      businessHours: json['businessHours'] ?? '',
      description: json['professionalDescription'] ?? 'Sin descripción profesional',
    );
  }
}

class ProfessionalsView extends StatefulWidget {
  const ProfessionalsView({super.key});

  @override
  State<ProfessionalsView> createState() => _ProfessionalsViewState();
}

class _ProfessionalsViewState extends State<ProfessionalsView>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  final Set<String> _favorites = {};

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  List<_Professional> _professionals = [];
  bool _isLoading = true;
  final ProfessionalApiService _apiService = ProfessionalApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
    _fadeController.forward();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    final token = await _storage.read(key: 'jwt_token') ?? '';
    final data = await _apiService.getProfessionals(token);
    final favIds = await _apiService.getFavoriteProfessionalIds(token);
    
    if (data != null && data['content'] != null) {
      final List<dynamic> content = data['content'];
      setState(() {
        _professionals = content.map((json) => _Professional.fromJson(json)).toList();
        _favorites.clear();
        _favorites.addAll(favIds);
        _isLoading = false;
      });
    } else {
      setState(() {
        _favorites.clear();
        _favorites.addAll(favIds);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(_Professional p) async {
    setState(() {
      if (_favorites.contains(p.id)) {
        _favorites.remove(p.id);
      } else {
        _favorites.add(p.id);
      }
    });

    final token = await _storage.read(key: 'jwt_token') ?? '';
    final success = await _apiService.toggleFavorite(token, p.id);
    if (!success) {
      if (mounted) {
        setState(() {
          if (_favorites.contains(p.id)) {
            _favorites.remove(p.id);
          } else {
            _favorites.add(p.id);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar favoritos')),
        );
      }
    }
  }

  void _openProfile(_Professional p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfessionalDetailView(
          professional: p,
          isFavorite: _favorites.contains(p.id),
          onToggleFavorite: () => _toggleFavorite(p),
          onRate: (stars) async {
            final token = await _storage.read(key: 'jwt_token') ?? '';
            final success = await _apiService.rateProfessional(token, p.id, stars);
            if (success) {
              _loadProfessionals();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _selectedTab == 0
        ? _professionals
        : _professionals.where((p) => _favorites.contains(p.id)).toList();

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
        title: Image.asset(
          'assets/images/Appoyo_logo.png',
          height: 65,
          errorBuilder: (_, __, ___) => const Text(
            'APPOYO',
            style: TextStyle(
              color: AppColors.appBarTitle,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 3,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1EEFA), width: 1),
                ),
                child: Row(
                  children: [
                    _Tab(
                      label: 'Para ti',
                      active: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                    _Tab(
                      label: 'Favoritos',
                      active: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_border_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aún no tienes favoritos',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Guarda profesionales que te interesen',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8EE), // Color gris claro
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      itemBuilder: (_, i) {
                        final p = list[i];
                        return _ProfessionalListItem(
                          professional: p,
                          isFavorite: _favorites.contains(p.id),
                          onToggleFavorite: () => _toggleFavorite(p),
                          onViewProfile: () => _openProfile(p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.primary : AppColors.textMuted,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfessionalListItem extends StatefulWidget {
  final _Professional professional;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onViewProfile;

  const _ProfessionalListItem({
    required this.professional,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onViewProfile,
  });

  @override
  State<_ProfessionalListItem> createState() => _ProfessionalListItemState();
}

class _ProfessionalListItemState extends State<_ProfessionalListItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.professional;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: widget.onViewProfile,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: Container(
          color: Colors.transparent, // Fondo transparente para usar divider afuera o sin borde
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: p.imageUrl.isNotEmpty ? NetworkImage(p.imageUrl) : null,
                    child: p.imageUrl.isEmpty
                        ? Text(
                            p.name.isNotEmpty ? p.name[0] : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Color(0xFFFFC940),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  p.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.handle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.experience,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.institution,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onToggleFavorite,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  widget.isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(widget.isFavorite),
                                  size: 24,
                                  color: widget.isFavorite
                                      ? const Color(0xFFE74C3C)
                                      : AppColors.textMuted.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (p.modalities.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p.modalities.join(' / '),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 34),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC780FF), // Violeta similar al mockup
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white), // Asumiendo que es un lock por el mockup
                                  SizedBox(width: 6),
                                  Text(
                                    'Ver Perfil',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Vista de Perfil Detallado (Pantalla Completa) ─────────────────────────────
class ProfessionalDetailView extends StatefulWidget {
  final _Professional professional;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Function(double) onRate;

  const ProfessionalDetailView({
    Key? key,
    required this.professional,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onRate,
  }) : super(key: key);

  @override
  State<ProfessionalDetailView> createState() => _ProfessionalDetailViewState();
}

class _ProfessionalDetailViewState extends State<ProfessionalDetailView> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.professional;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () => _showRatingDialog(context, p.name, widget.onRate),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC780FF), // Violeta del mockup
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Evaluar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? const Color(0xFFE74C3C) : AppColors.textPrimary,
              size: 26,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              widget.onToggleFavorite();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image con Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  height: 380,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen de fondo
                      p.imageUrl.isNotEmpty
                          ? Image.network(p.imageUrl, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.person, size: 100, color: AppColors.primary),
                            ),
                      // Gradiente oscuro en la parte inferior
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      // Info superpuesta
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.handle.replaceAll('@', ''),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    p.city.isNotEmpty ? p.city : 'Ubicación no especificada',
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                ),
                                const Icon(Icons.star_rounded, color: Color(0xFFFFC940), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  p.rating.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Iconos de Horario y Modalidad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.textPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    p.businessHours.isNotEmpty ? p.businessHours : 'Horario no especificado',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.calendar_today_rounded, color: AppColors.textPrimary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    p.modalities.isNotEmpty ? p.modalities.join(' / ') : 'Presencial',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sección Perfil Profesional
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Perfil Profesional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                p.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String name, Function(double) onRate) {
    double selectedStars = 5.0;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Calificar a $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStars ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFFC940),
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedStars = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    onRate(selectedStars);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Gracias por tu calificación!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enviar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
