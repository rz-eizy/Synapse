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

  const _Professional({
    required this.id,
    required this.name,
    required this.handle,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.institution,
    this.modalities = const [],
  });

  factory _Professional.fromJson(Map<String, dynamic> json) {
    return _Professional(
      id: json['professionalId'] ?? '',
      name: json['username'] ?? 'Desconocido',
      handle: '@${json['professionName'] ?? 'Profesional'}',
      imageUrl: json['profilePictureUrl'] ?? '',
      rating: (json['averageStars'] ?? 0.0).toDouble(),
      experience: json['currentWork'] ?? '',
      institution: 'Institución',
      modalities: ['Presencial', 'Remoto'],
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
    
    if (data != null && data['content'] != null) {
      final List<dynamic> content = data['content'];
      setState(() {
        _professionals = content.map((json) => _Professional.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String handle) {
    setState(() {
      if (_favorites.contains(handle)) {
        _favorites.remove(handle);
      } else {
        _favorites.add(handle);
      }
    });
  }

  void _openProfile(_Professional p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfessionalProfileSheet(
        professional: p,
        isFavorite: _favorites.contains(p.handle),
        onToggleFavorite: () => _toggleFavorite(p.handle),
        onRate: (stars) async {
          final token = await _storage.read(key: 'jwt_token') ?? '';
          final success = await _apiService.rateProfessional(token, p.id, stars);
          if (success) {
            _loadProfessionals();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _selectedTab == 0
        ? _professionals
        : _professionals.where((p) => _favorites.contains(p.handle)).toList();

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
          'assets/images/AppBar_logoAppoyo.png',
          height: 28,
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
            // ── Tab selector premium ──────────────────────────────────────
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

            // ── Lista de Tarjetas Rediseñadas ──────────────────────────────
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
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProfessionalListItem(
                            professional: p,
                            isFavorite: _favorites.contains(p.handle),
                            onToggleFavorite: () => _toggleFavorite(p.handle),
                            onViewProfile: () => _openProfile(p),
                          ),
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

// ── Tab del selector ──────────────────────────────────────────────────────────
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

// ── Ítem de la lista (Tarjeta Premium con Alineación Fija Coherente) ──────────
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
      scale: _isPressed ? 0.99 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF1EEFA), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onViewProfile,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Info y Badge de Calificación
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.12),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: p.imageUrl.isNotEmpty
                            ? NetworkImage(p.imageUrl)
                            : null,
                        child: p.imageUrl.isEmpty
                            ? Text(
                                p.name.isNotEmpty ? p.name[0] : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            p.handle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFFC940),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            p.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A6800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Institución y Experiencia
                Text(
                  '${p.experience} · ${p.institution}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                Divider(color: AppColors.divider.withOpacity(0.3), height: 1),
                const SizedBox(height: 12),

                // Fila Inferior con Bloques Alineados Estáticamente
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bloque Izquierdo: Iconos de Modalidad Representativos
                    if (p.modalities.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: p.modalities.map((m) {
                          final bool isRemote = m.toLowerCase() == 'remoto';
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Tooltip(
                              message: m,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isRemote
                                      ? const Color(0xFFE3F2FD)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isRemote
                                      ? Icons.devices_rounded
                                      : Icons.location_on_rounded,
                                  size: 16,
                                  color: isRemote
                                      ? const Color(0xFF1E88E5)
                                      : const Color(0xFF43A047),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const SizedBox(
                        height: 34,
                      ), // Espacio de reserva si no hay modalidades
                    // Bloque Central: El Spacer empuja uniformemente el bloque de la derecha sin importar qué pase a la izquierda
                    const Spacer(),

                    // Bloque Derecho: Acciones agrupadas para que NUNCA se muevan de su eje derecho
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: widget.onViewProfile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Ver perfil',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: widget.onToggleFavorite,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              key: ValueKey(widget.isFavorite),
                              size: 24,
                              color: widget.isFavorite
                                  ? const Color(0xFFFFC940)
                                  : AppColors.textMuted.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sheet de perfil detallado ─────────────────────────────────────────────────
class _ProfessionalProfileSheet extends StatefulWidget {
  final _Professional professional;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Function(double) onRate;

  const _ProfessionalProfileSheet({
    required this.professional,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onRate,
  });

  @override
  State<_ProfessionalProfileSheet> createState() =>
      _ProfessionalProfileSheetState();
}

class _ProfessionalProfileSheetState extends State<_ProfessionalProfileSheet> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.professional;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8EE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header del bottom sheet
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: p.imageUrl.isNotEmpty
                      ? NetworkImage(p.imageUrl)
                      : null,
                  child: p.imageUrl.isEmpty
                      ? Text(
                          p.name.isNotEmpty ? p.name[0] : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.handle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _showRatingDialog(context, p.name, widget.onRate),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFC940),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8A6800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _isFavorite = !_isFavorite);
                  widget.onToggleFavorite();
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    _isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    key: ValueKey(_isFavorite),
                    size: 28,
                    color: _isFavorite
                        ? const Color(0xFFFFC940)
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: const Color(0xFFF0F0F5)),
          const SizedBox(height: 20),

          // Detalles descriptivos en el Sheet
          _DetailRow(icon: Icons.school_outlined, text: p.institution),
          const SizedBox(height: 14),
          _DetailRow(icon: Icons.work_outline_rounded, text: p.experience),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.place_outlined,
            text: p.modalities.isNotEmpty
                ? 'Atención ${p.modalities.join(' / ')}'
                : 'Modalidad no especificada',
          ),
          const SizedBox(height: 28),

          // Botón contactar premium unificado
          _ContactButton(onPressed: () {}),
        ],
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ContactButton({required this.onPressed});

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
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
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _pressed
                  ? [
                      AppColors.primary.withOpacity(0.88),
                      const Color(0xFF7B2FBE),
                    ]
                  : [AppColors.primary, const Color(0xFF8B3FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Contactar / Agendar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
