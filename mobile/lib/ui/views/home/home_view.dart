import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/professional_card.dart';
import '../account/account_view.dart';
import '../../widgets/community_card.dart';
import '../../../core/services/publicationService.dart';
import '../../../core/models/publicationModel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/comments_sheet.dart';
import 'package:mobile/core/services/commentService.dart';
import 'package:mobile/core/models/commentModel.dart';
import 'professional_view.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  int _selectedTab = 0;
  int _selectedNav = 0;

  final _comunidadListKey = GlobalKey<_ComunidadListState>();

  // Tour
  bool _showTour = true;
  int _tourStep  = 0;

  // GlobalKeys
  final _keyTabs       = GlobalKey();
  final _keyFirstCard  = GlobalKey();
  final _keyBottomNav  = GlobalKey();

  List<_TourStep> _buildSteps() {
    final size = MediaQuery.of(context).size;

    Rect rectOf(GlobalKey key, {double pad = 10}) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) {
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
      _TourStep(
        title: '¡Bienvenido/a a Appoyo! 👋',
        description:
            'Te hacemos un recorrido rápido por las partes principales de la app para que puedas aprovecharla al máximo.',
        highlightRect: Rect.zero,
      ),
      _TourStep(
        title: 'Profesionales y Comunidad',
        description:
            'Cambia entre publicaciones de especialistas en salud mental y posts de la comunidad usando estos tabs.',
        highlightRect: rectOf(_keyTabs),
      ),
      _TourStep(
        title: 'Publicaciones',
        description:
            'Aquí aparecen los posts. Puedes comentar 💬 y dar like ❤️ con los botones de cada tarjeta.',
        highlightRect: rectOf(_keyFirstCard),
      ),
      _TourStep(
        title: 'Navegación principal',
        description:
            '"Inicio" te trae aquí. "Publicar" crea un nuevo post. "Profesionales" lista todos los especialistas disponibles.',
        highlightRect: rectOf(_keyBottomNav),
      ),
      _TourStep(
        title: '¡Todo listo!',
        description: 'Ya conoces lo esencial. Esperamos que disfrutes de Appoyo!',
        highlightRect: Rect.zero,
      ),
    ];
  }

  void _openPublishSheet() {
    final contentController  = TextEditingController();
    final hashtagController  = TextEditingController();
    final ImagePicker picker = ImagePicker();

    bool canPublish    = false;
    bool isUploading   = false;
    int charCount      = 0;
    const int maxChars = 280;
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void updatePublishState() {
              setSheetState(() {
                charCount   = contentController.text.length;
                canPublish  = (contentController.text.trim().isNotEmpty ||
                        selectedImage != null) &&
                    charCount <= maxChars &&
                    !isUploading;
              });
            }

            contentController.addListener(updatePublishState);

            Future<void> pickImage() async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                selectedImage = File(image.path);
                updatePublishState();
              }
            }

            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            final remaining   = maxChars - charCount;
            final isNearLimit = remaining <= 20;

            return Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  const SizedBox(height: 14),
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

                  // Barra superior
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Nueva publicación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(sheetContext),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        AnimatedOpacity(
                          opacity: canPublish ? 1.0 : 0.38,
                          duration: const Duration(milliseconds: 180),
                          child: GestureDetector(
                            onTap: canPublish
                                ? () async {
                                    setSheetState(() => isUploading = true);
                                    final textContent =
                                        contentController.text.trim();
                                    const storage = FlutterSecureStorage();
                                    String? jwtToken =
                                        await storage.read(key: 'jwt_token');
                                    const region = 'Araucanía';

                                    if (jwtToken == null ||
                                        jwtToken.isEmpty) {
                                      if (!sheetContext.mounted) return;
                                      ScaffoldMessenger.of(sheetContext)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Error de autenticación.')));
                                      setSheetState(
                                          () => isUploading = false);
                                      return;
                                    }

                                    final apiService = PublicationApiService();
                                    String? finalImageUrl;

                                    if (selectedImage != null) {
                                      final urls = await apiService
                                          .getUploadURLs(jwtToken, 'image/jpeg');
                                      if (urls != null) {
                                        bool uploaded = await apiService
                                            .uploadImageToCloudFlare(
                                                urls['uploadUrl']!,
                                                selectedImage!,
                                                'image/jpeg');
                                        if (uploaded) {
                                          finalImageUrl = urls['publicUrl'];
                                        } else {
                                          if (!sheetContext.mounted) return;
                                          ScaffoldMessenger.of(sheetContext)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Error al subir la imagen.')));
                                          setSheetState(
                                              () => isUploading = false);
                                          return;
                                        }
                                      }
                                    }

                                    bool success =
                                        await apiService.createPublication(
                                            jwtToken,
                                            textContent,
                                            finalImageUrl,
                                            region);

                                    if (success) {
                                      if (!sheetContext.mounted) return;
                                      Navigator.pop(sheetContext);
                                      setState(() {
                                        _selectedTab = 1;
                                        _selectedNav = 0;
                                      });
                                      _comunidadListKey.currentState
                                          ?._refreshPublications();
                                    } else {
                                      if (!sheetContext.mounted) return;
                                      ScaffoldMessenger.of(sheetContext)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Error del servidor.')));
                                      setSheetState(
                                          () => isUploading = false);
                                    }
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 9),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, Color(0xFF8B3FD4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: isUploading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text(
                                      'Publicar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(height: 1, color: const Color(0xFFF0F0F5)),

                  // Área de escritura
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person,
                              size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: contentController,
                                maxLines: 6,
                                minLines: 3,
                                maxLength: maxChars,
                                buildCounter: (_, {required currentLength,
                                        required isFocused, maxLength}) =>
                                    null,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                  height: 1.55,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '¿Qué quieres compartir hoy?',
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(height: 1, color: const Color(0xFFF0F0F5)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.tag,
                                      size: 15, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: TextField(
                                      controller: hashtagController,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Agrega hashtags',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Preview imagen
                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 54, right: 20, bottom: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(selectedImage!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                selectedImage = null;
                                updatePublishState();
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Container(height: 1, color: const Color(0xFFF0F0F5)),

                  // Barra inferior
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 20, 18),
                    child: Row(
                      children: [
                        if (_selectedTab == 0)
                          IconButton(
                            icon: const Icon(Icons.image_outlined,
                                color: AppColors.primary),
                            onPressed: pickImage,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        else
                          const SizedBox(width: 24),
                        const Spacer(),
                        Text(
                          '$remaining',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isNearLimit
                                ? (remaining < 0
                                    ? AppColors.error
                                    : AppColors.warning)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        Scaffold(
          backgroundColor: const Color(0xFFFAFAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFF0F0F5)),
            ),
            title: Image.asset(
              'assets/images/AppBar_logoAppoyo.png',
              height: 26,
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountView()),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.person,
                          size: 17, color: AppColors.primary),
                    ),
                  ),
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
              Expanded(
                child: _selectedTab == 0
                    ? _ProfessionalesList(firstCardKey: _keyFirstCard)
                    : _ComunidadList(
                        key: _comunidadListKey,
                        firstCardKey: _keyFirstCard,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            key: _keyBottomNav,
            selectedIndex: _selectedNav,
            onTap: (i) {
              if (i == 1) {
                _openPublishSheet();
              } else if (i == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfessionalsView()),
                );
              } else {
                setState(() => _selectedNav = i);
              }
            },
          ),
        ),

        // Tour overlay
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

// ── Tour ──────────────────────────────────────────────────────────────────────
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
          CustomPaint(
            size: size,
            painter: _DimPainter(highlight: step.highlightRect),
          ),
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
      ..addRRect(
          RRect.fromRectAndRadius(highlight, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
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
    if (step.highlightRect == Rect.zero) return (screenH - bubbleH) / 2;
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
        onTap: () {},
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF0F0F5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress dots
                Row(
                  children: List.generate(totalSteps, (i) {
                    final active = i == currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 5),
                      width: active ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isLast)
                      TextButton(
                        onPressed: onSkip,
                        child: const Text(
                          'Saltar',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    GestureDetector(
                      onTap: onNext,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF8B3FD4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          isLast ? '¡Entendido!' : 'Siguiente →',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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

// ── Tab Selector ──────────────────────────────────────────────────────────────
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F5), width: 1),
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
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

// ── Listas ────────────────────────────────────────────────────────────────────
class _ProfessionalesList extends StatelessWidget {
  final GlobalKey? firstCardKey;
  const _ProfessionalesList({this.firstCardKey});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
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

class _CommunityPost {
  final String userName;
  final String userImageUrl;
  final String date;
  final String content;
  final List<String> hashtags;

  const _CommunityPost({
    required this.userName,
    required this.userImageUrl,
    required this.date,
    required this.content,
    this.hashtags = const [],
  });
}

class _ComunidadList extends StatefulWidget {
  final GlobalKey? firstCardKey;
  const _ComunidadList({super.key, this.firstCardKey});

  @override
  State<_ComunidadList> createState() => _ComunidadListState();
}

class _ComunidadListState extends State<_ComunidadList> {
  final PublicationApiService _apiService = PublicationApiService();
  final _storage = const FlutterSecureStorage();
  late Future<List<PublicationModel>> _futurePublications;
  final String _region = 'Araucanía';

  @override
  void initState() {
    super.initState();
    _refreshPublications();
  }

  void _refreshPublications() {
    setState(() {
      _futurePublications = _loadPublicationsWithToken();
    });
  }

  Future<List<PublicationModel>> _loadPublicationsWithToken() async {
    final token = await _storage.read(key: 'jwt_token') ?? '';
    if (token.isEmpty) {
      throw Exception(
          'Sesión expirada o no autenticado. Inicie sesión nuevamente.');
    }
    return _apiService.fetchPublications(token, _region);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PublicationModel>>(
      future: _futurePublications,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFC),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF0F0F5)),
                    ),
                    child: const Icon(Icons.wifi_off_outlined,
                        size: 30, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al conectar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Revisa tu conexión e intenta de nuevo',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No hay publicaciones en esta región.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final posts = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final p = posts[i];
            return CommunityCard(
              key: i == 0 ? widget.firstCardKey : null,
              id: p.id,
              userName: p.authorName,
              userImageUrl: p.authorImageUrl ?? '',
              postImageUrl: p.imageUrl,
              date: '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
              content: p.content,
              commentCount: p.commentsCount,
              likeCount: p.likesCount,
              hashtags: const [],
            );
          },
        );
      },
    );
  }
}

// ── Bottom Nav flotante ───────────────────────────────────────────────────────
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0F0F5), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Inicio',
                active: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItemPublish(onTap: () => onTap(1)),
              _NavItem(
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
                label: 'Profesionales',
                active: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                active ? activeIcon : icon,
                key: ValueKey(active),
                size: 22,
                color: active ? AppColors.primary : AppColors.navInactive,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.primary : AppColors.navInactive,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón central de publicar
class _NavItemPublish extends StatefulWidget {
  final VoidCallback onTap;
  const _NavItemPublish({required this.onTap});

  @override
  State<_NavItemPublish> createState() => _NavItemPublishState();
}

class _NavItemPublishState extends State<_NavItemPublish> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedScale(
            scale: _pressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF8B3FD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _pressed
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}