import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/professional_card.dart';
import '../../widgets/community_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedTab = 0; // 0 = Profesionales, 1 = Comunidad
  int _selectedNav = 0; // 0 = Inicio, 1 = Publicar, 2 = Profesionales

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // appBar ----------------------
      appBar: AppBar(
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/AppBar_logoAppoyo.png', height: 28),
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

      // body -------------------
      body: Column(
        children: [
          // selección profesionales/comunidad ---------------------------
          _TabSelector(
            selectedTab: _selectedTab,
            onTabChanged: (i) => setState(() => _selectedTab = i),
          ),
          const SizedBox(height: 8),

          // lista según tab activo -------------------------
          Expanded(
            child: _selectedTab == 0 ? _ProfessionalesList() : _ComunidadList(),
          ),
        ],
      ),

      // boton navigation
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedNav,
        onTap: (i) => setState(() => _selectedNav = i),
      ),
    );
  }
}

// tab selector de pagina ----------------------
class _TabSelector extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _TabSelector({required this.selectedTab, required this.onTabChanged});

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// lista profesional ---------------------------
class _ProfessionalesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: const [
        ProfessionalCard(
          name: 'Nathalie Espinoza',
          handle: '@Psicóloga',
          profession: 'Psicóloga Clínica',
          imageUrl: '',
          date: '01/05/26',
          description:
              'Soy Psicóloga Clínica, titulada de la Pontificia Universidad Católica de Chile, especializada en la atención de pacientes adultos. En 2024 cursé el Diplomado en "Avances en Psicoterapia: Teoría y Técnica" impartido por el CEFOP (Argentina), lo que me permitió profundizar en la integración de distintos enfoques psicoterapéuticos.',
          hashtags: ['#Psicoanálisis', '#Videollamada', '#Presencial'],
        ),
        ProfessionalCard(
          name: 'Juan José Roca',
          handle: '@Psiquiatra',
          profession: 'Psiquiatra',
          imageUrl: '',
          date: '29/04/26',
          description:
              'Soy psiquiatra de la Universidad de Chile y mi enfoque está centrado en el tratamiento de trastornos del ánimo y ansiedad con una perspectiva integrativa.',
          hashtags: ['#Psiquiatría', '#Presencial'],
        ),
      ],
    );
  }
}

// lista comunidad -------------------------------
class _ComunidadList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: const [
        CommunityCard(
          userName: 'Eloy Prado',
          userImageUrl: '',
          date: '29/04/26',
          content:
              '¡Feliz fin de semana! 😄 Que Diosito los bendiga hoy y siempre. Un abracito virtual 🤗',
          hashtags: ['#Appoyo', '#BuenosDías', '#Amor'],
          commentCount: 3,
          likeCount: 0,
        ),
        CommunityCard(
          userName: 'Tomás Suárez',
          userImageUrl: '',
          date: '27/04/26',
          content:
              'Alguien sabe como hacer arroz con pollo? esque se me quemo el que estaba cocinando',
          hashtags: ['#Comunidad'],
          commentCount: 1,
          likeCount: 0,
        ),
        CommunityCard(
          userName: 'Camila Echeverria',
          userImageUrl: '',
          date: '01/05/26',
          content:
              'hola, mi nombre es Cami y me presento tanto a mi como a mi niño Daniel. Buen día.',
          hashtags: ['#Appoyo', '#BuenosDías', '#Amor'],
          commentCount: 0,
          likeCount: 0,
        ),
        CommunityCard(
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

// ── Bottom Navigation Bar ────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

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
