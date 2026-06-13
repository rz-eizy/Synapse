import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Modelo de datos para un profesional ─────────────────────────────────────
class _Professional {
  final String name;
  final String handle;
  final String imageUrl;
  final double rating;
  final String experience;
  final String institution;
  final List<String> modalities;

  const _Professional({
    required this.name,
    required this.handle,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.institution,
    this.modalities = const [],
  });
}

class ProfessionalsView extends StatefulWidget {
  const ProfessionalsView({super.key});

  @override
  State<ProfessionalsView> createState() => _ProfessionalsViewState();
}

class _ProfessionalsViewState extends State<ProfessionalsView> {
  int _selectedTab = 0; // 0 = Para ti, 1 = Favoritos
  final Set<String> _favorites = {};

  static const List<_Professional> _professionals = [
    _Professional(
      name: 'Nathalie Espinoza',
      handle: '@Medico',
      imageUrl: '',
      rating: 4.1,
      experience: '3 años de experiencia',
      institution: 'Universidad de Concepción',
      modalities: ['Presencial', 'Remoto'],
    ),
    _Professional(
      name: 'Juan José Roca',
      handle: '@Psicólogo',
      imageUrl: '',
      rating: 4.5,
      experience: '37 años de experiencia',
      institution: 'Pontificia Universidad Católica de Chile',
      modalities: ['Presencial'],
    ),
    _Professional(
      name: 'Siomara Zapata',
      handle: '@Psicóloga',
      imageUrl: '',
      rating: 4.9,
      experience: '20 años de experiencia',
      institution: 'Universidad de Chile',
      modalities: ['Remoto'],
    ),
    _Professional(
      name: 'Jessica Parra',
      handle: '@Psicóloga',
      imageUrl: '',
      rating: 4.7,
      experience: '10 años de experiencia',
      institution: 'Universidad Austral de Chile',
      modalities: ['Presencial', 'Remoto'],
    ),
  ];

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _selectedTab == 0
        ? _professionals
        : _professionals.where((p) => _favorites.contains(p.handle)).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/AppBar_logoAppoyo.png',
          height: 28,
          errorBuilder: (_, __, ___) => const Text(
            'APPOYO',
            style: TextStyle(
              color: AppColors.appBarTitle,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 3,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Selector de tabs "Para ti / Favoritos" ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(30),
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

          // ── Lista de profesionales ──────────────────────────────────────
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_border,
                            size: 48, color: AppColors.primaryLight),
                        const SizedBox(height: 12),
                        const Text(
                          'Aún no tienes favoritos',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFEEE5F5)),
                    itemBuilder: (_, i) {
                      final p = list[i];
                      return _ProfessionalListItem(
                        professional: p,
                        isFavorite: _favorites.contains(p.handle),
                        onToggleFavorite: () => _toggleFavorite(p.handle),
                        onViewProfile: () => _openProfile(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Tab del selector ─────────────────────────────────────────────────────────
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
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ítem de la lista de profesionales ─────────────────────────────────────────
class _ProfessionalListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final p = professional;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: avatar + nombre/handle + rating + favorito ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      p.handle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFC940)),
                  const SizedBox(width: 4),
                  Text(
                    p.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // experiencia / institución ------------------------------------
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Text(
              '${p.experience}\n${p.institution}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // modalidad + botón ver perfil + favorito ----------------------
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Row(
              children: [
                // Chip de modalidad
                if (p.modalities.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        p.modalities.join(' / '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                const SizedBox(width: 10),

                // Botón Ver Perfil
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: onViewProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.badge_outlined, size: 16),
                      label: const Text('Ver Perfil'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Favorito
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    size: 24,
                    color: isFavorite
                        ? const Color(0xFFFFC940)
                        : AppColors.textMuted,
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

// ── Sheet con el perfil detallado del profesional ──────────────────────────────
class _ProfessionalProfileSheet extends StatefulWidget {
  final _Professional professional;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ProfessionalProfileSheet({
    required this.professional,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<_ProfessionalProfileSheet> createState() =>
      _ProfessionalProfileSheetState();
}

class _ProfessionalProfileSheetState
    extends State<_ProfessionalProfileSheet> {
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header: avatar + nombre + favorito ---------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
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
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      p.handle,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFFFC940)),
                        const SizedBox(width: 4),
                        Text(
                          p.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _isFavorite = !_isFavorite);
                  widget.onToggleFavorite();
                },
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  size: 26,
                  color: _isFavorite
                      ? const Color(0xFFFFC940)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEE5F5)),
          const SizedBox(height: 16),

          // Detalle de experiencia / institución ---------------------------
          _DetailRow(icon: Icons.school_outlined, text: p.institution),
          const SizedBox(height: 10),
          _DetailRow(icon: Icons.work_outline, text: p.experience),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.place_outlined,
            text: p.modalities.isNotEmpty
                ? 'Atención ${p.modalities.join(' / ')}'
                : 'Modalidad no especificada',
          ),
          const SizedBox(height: 24),

          // Botón agendar / contactar -------------------------------------
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
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                // TODO: flujo de agendamiento / contacto
              },
              child: const Text('Contactar / Agendar'),
            ),
          ),
        ],
      ),
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
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}