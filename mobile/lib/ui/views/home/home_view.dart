import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/professional_card.dart';
import '../../widgets/community_card.dart';

class _TourStep {
  final String title;
  final String description;
  final Rect highlightRect;

  const _TourStep({
    required this.title,
    required this.description,
    required this.highlightRect,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedTab = 0;
  int _selectedNav = 0;

  // Tour ----------------
  // reemplazar con SharedPreferences para mostrarlo solo la primera vez (para testing queda asi momentáneamente)
  bool _showTour = true;
  int _tourStep = 0;

  // GlobalKeys ---------------
  final _keyTabs = GlobalKey();
  final _keyFirstCard = GlobalKey();
  final _keyBottomNav = GlobalKey();

  // Construye los pasos una vez que el layout ya existe -------------------
  List<_TourStep> _buildSteps() {
    final size = MediaQuery.of(context).size;

    Rect rectOf(GlobalKey key, {double pad = 10}) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) {
        // fallback centrado si el widget aún no está en pantalla --------------
        return Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.8,
          height: 60,
        );
      }
      final pos = box.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        pos.dx - pad,
        pos.dy - pad,
        box.size.width + pad * 2,
        box.size.height + pad * 2,
      );
    }

    return [
      // Bienvenida ------------ (Paso 1)
      _TourStep(
        title: '¡Bienvenido/a a Appoyo! 👋',
        description:
            'Te hacemos un recorrido rápido por las partes principales de la app para que puedas aprovecharla al máximo.',
        highlightRect: Rect.zero,
      ),
      // Tabs ------------ (Paso 2)
      _TourStep(
        title: 'Profesionales y Comunidad',
        description:
            'Cambia entre publicaciones de especialistas en salud mental y posts de la comunidad usando estos tabs.',
        highlightRect: rectOf(_keyTabs),
      ),
      // Card ------------ (Paso 3)
      _TourStep(
        title: 'Publicaciones',
        description:
            'Aquí aparecen los posts. Puedes comentar 💬 y dar like ❤️ con los botones de cada tarjeta.',
        highlightRect: rectOf(_keyFirstCard),
      ),
      // Bottom nav ------------ (Paso 4)
      _TourStep(
        title: 'Navegación principal',
        description:
            '"Inicio" te trae aquí. "Publicar" crea un nuevo post. "Profesionales" lista todos los especialistas disponibles.',
        highlightRect: rectOf(_keyBottomNav),
      ),
      // Fin ------------ (Paso 5)
      _TourStep(
        title: '¡Todo listo!',
        description:
            'Ya conoces lo esencial. Esperamos que disfrutes de Appoyo!',
        highlightRect: Rect.zero,
      ),
    ];
  }

  void _nextStep() {
    final steps = _buildSteps();
    if (_tourStep < steps.length - 1) {
      setState(() => _tourStep++);
    } else {
      setState(() => _showTour = false);
    }
  }

  void _skipTour() => setState(() => _showTour = false);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // pantalla real home -----------------------
        Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.appBarBg,
            elevation: 0,
            automaticallyImplyLeading: false,
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: const NetworkImage(''),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _TabSelector(
                key: _keyTabs,
                selectedTab: _selectedTab,
                onTabChanged: (i) => setState(() => _selectedTab = i),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _selectedTab == 0
                    ? _ProfessionalesList(firstCardKey: _keyFirstCard)
                    : _ComunidadList(firstCardKey: _keyFirstCard),
              ),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            key: _keyBottomNav,
            selectedIndex: _selectedNav,
            onTap: (i) => setState(() => _selectedNav = i),
          ),
        ),

        // tour overlay ----------------------
        if (_showTour)
          _TourOverlay(
            steps: _buildSteps(),
            currentStep: _tourStep,
            onNext: _nextStep,
            onSkip: _skipTour,
          ),
      ],
    );
  }
}

class _TourOverlay extends StatelessWidget {
  final List<_TourStep> steps;
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TourOverlay({
    required this.steps,
    required this.currentStep,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          // Fondo oscuro con agujero en el highlight -------------------
          CustomPaint(
            size: size,
            painter: _DimPainter(highlight: step.highlightRect),
          ),
          // Globo explicativo ---------------
          _TourBubble(
            step: step,
            currentStep: currentStep,
            totalSteps: steps.length,
            isLast: currentStep == steps.length - 1,
            onNext: onNext,
            onSkip: onSkip,
          ),
        ],
      ),
    );
  }
}

class _DimPainter extends CustomPainter {
  final Rect highlight;
  const _DimPainter({required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.72);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(highlight, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Borde morado alrededor del área resaltada ---------------
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlight, const Radius.circular(16)),
      Paint()
        ..color = AppColors.primary.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.highlight != highlight;
}

// globo de texto ---------------------
class _TourBubble extends StatelessWidget {
  final _TourStep step;
  final int currentStep;
  final int totalSteps;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TourBubble({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  double _bubbleTop(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    const bubbleH = 230.0;

    // Si no hay highlight, centrar verticalmente
    if (step.highlightRect == Rect.zero) {
      return (screenH - bubbleH) / 2;
    }

    const margin = 20.0;
    final below = step.highlightRect.bottom + margin;
    if (below + bubbleH < screenH - 20) return below;
    final above = step.highlightRect.top - bubbleH - margin;
    return above.clamp(margin, screenH - bubbleH - margin);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _bubbleTop(context),
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {}, // evita propagación
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de pasos (dots animados)
                Row(
                  children: List.generate(totalSteps, (i) {
                    final active = i == currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: active ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Título
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Descripción
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isLast)
                      TextButton(
                        onPressed: onSkip,
                        child: const Text(
                          'Saltar tour',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      onPressed: onNext,
                      child: Text(
                        isLast ? '¡Entendido!' : 'Siguiente →',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _TabSelector extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _TabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _Tab(
              label: 'Profesionales',
              active: selectedTab == 0,
              onTap: () => onTabChanged(0),
            ),
            _Tab(
              label: 'Comunidad',
              active: selectedTab == 1,
              onTap: () => onTabChanged(1),
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

class _ProfessionalesList extends StatelessWidget {
  final GlobalKey? firstCardKey;
  const _ProfessionalesList({this.firstCardKey});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        ProfessionalCard(
          key: firstCardKey,
          name: 'Nathalie Espinoza',
          handle: '@Psicóloga',
          profession: 'Psicóloga Clínica',
          imageUrl: '',
          date: '01/05/26',
          description:
              'Soy Psicóloga Clínica, titulada de la Pontificia Universidad Católica de Chile, especializada en la atención de pacientes adultos.',
          hashtags: const ['#Psicoanálisis', '#Videollamada', '#Presencial'],
        ),
        const ProfessionalCard(
          name: 'Juan José Roca',
          handle: '@Psiquiatra',
          profession: 'Psiquiatra',
          imageUrl: '',
          date: '29/04/26',
          description:
              'Soy psiquiatra de la Universidad de Chile y mi enfoque está centrado en el tratamiento de trastornos del ánimo y ansiedad.',
          hashtags: ['#Psiquiatría', '#Presencial'],
        ),
      ],
    );
  }
}

class _ComunidadList extends StatelessWidget {
  final GlobalKey? firstCardKey;
  const _ComunidadList({this.firstCardKey});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        CommunityCard(
          key: firstCardKey,
          userName: 'Eloy Prado',
          userImageUrl: '',
          date: '29/04/26',
          content:
              '¡Feliz fin de semana! 😄 Que Diosito los bendiga hoy y siempre. Un abracito virtual 🤗',
          hashtags: const ['#Appoyo', '#BuenosDías', '#Amor'],
          commentCount: 3,
          likeCount: 0,
        ),
        const CommunityCard(
          userName: 'Tomás Suárez',
          userImageUrl: '',
          date: '27/04/26',
          content:
              'Alguien sabe como hacer arroz con pollo? esque se me quemo el que estaba cocinando',
          hashtags: ['#Comunidad'],
          commentCount: 1,
          likeCount: 0,
        ),
        const CommunityCard(
          userName: 'Camila Echeverria',
          userImageUrl: '',
          date: '01/05/26',
          content:
              'hola, mi nombre es Cami y me presento tanto a mi como a mi niño Daniel. Buen día.',
          hashtags: ['#Appoyo', '#BuenosDías', '#Amor'],
          commentCount: 0,
          likeCount: 0,
        ),
        const CommunityCard(
          userName: 'Mariane Sanchez',
          userImageUrl: '',
          date: '30/04/26',
          content:
              'Busco ayuda para resolver unas dudas, alguien que pueda orientarme?',
          hashtags: ['#Comunidad'],
          commentCount: 0,
          likeCount: 0,
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor: AppColors.navActive,
      unselectedItemColor: AppColors.navInactive,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      backgroundColor: AppColors.background,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Publicar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Profesionales',
        ),
      ],
    );
  }
}
