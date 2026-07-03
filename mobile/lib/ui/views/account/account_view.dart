import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/comments_sheet.dart';
import 'editAccount_view.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/userService.dart';
import '../../widgets/upgrade_professional_dialog.dart';
import '../../../core/models/publicationModel.dart';
import '../../widgets/community_card.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView>
    with TickerProviderStateMixin {
  final UserApiService _apiService = UserApiService();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  String _username = 'Usuario';
  String _profileImageUrl = '';
  String _userRole = 'regular';
  List<PublicationModel> _userPosts = [];

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _isProfessional = false;

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
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final token = await _storage.read(key: 'jwt_token') ?? '';
    if (token.isEmpty) return;

    final profileData = await _apiService.getMyProfile(token);

    if (profileData != null && mounted) {
      final publicationsJson =
          profileData['publications'] as List<dynamic>? ?? [];

      setState(() {
        _username = profileData['username'] ?? 'Usuario';
        _profileImageUrl = profileData['profilePictureUrl'] ?? '';
        _isProfessional = profileData['role'] == 'professional';
        
        if (_isProfessional && profileData['professional'] != null && profileData['professional']['professionName'] != null) {
          _userRole = profileData['professional']['professionName'];
        } else {
          _userRole = profileData['role'] ?? 'regular';
        }

        _userPosts = publicationsJson
            .map((pub) => PublicationModel.fromJson(pub as Map<String, dynamic>))
            .toList();

        _isLoading = false;
      });
      _fadeController.forward();
    } else {
      setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
          'Mi Perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _ProfileHeader(
                      username: _username,
                      userRole: _userRole,
                      profileImageUrl: _profileImageUrl,
                      postCount: _userPosts.length,
                      isProfessional: _isProfessional,
                    ),
                  ),
                  // Indicador de feed premium estilo Tab
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.primary,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_on_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Mis Posts',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Grid de posts con estética redondeada premium
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _PostThumbnail(post: _userPosts[i]),
                        childCount: _userPosts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Header de perfil ──────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String username;
  final String userRole;
  final String profileImageUrl;
  final int postCount;
  final bool isProfessional;

  const _ProfileHeader({
    required this.username,
    required this.userRole,
    required this.profileImageUrl,
    required this.postCount,
    required this.isProfessional,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          // Avatar refinado con doble borde/sombra
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.12),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl.isEmpty
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          // Nombres e Identificadores
          Text(
            username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '@${userRole.toLowerCase()}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Bio Limpia
          const Text(
            '¡Hola, bienvenido a mi perfil!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Fila de Info + Botón de Edición
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1EEFA), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      '$postCount',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: Color(0xFFF1EEFA),
                        width: 1.5,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditAccountView(),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Editar perfil'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isProfessional) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const UpgradeProfessionalDialog(),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Ascender a profesional'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Thumbnails Interactivos de la Grilla ──────────────────────────────────────
class _PostThumbnail extends StatefulWidget {
  final PublicationModel post;
  const _PostThumbnail({required this.post});

  @override
  State<_PostThumbnail> createState() => _PostThumbnailState();
}

class _PostThumbnailState extends State<_PostThumbnail> {
  late int _likes;
  late int _commentCount;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likesCount;
    _commentCount = widget.post.commentsCount;
  }

  void _openDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              CommunityCard(
                id: widget.post.id,
                userName: widget.post.authorName,
                userRole: widget.post.authorRole,
                userImageUrl: widget.post.authorImageUrl ?? '',
                postImageUrl: widget.post.imageUrl,
                date: '${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}',
                content: widget.post.content,
                likeCount: _likes,
                commentCount: _commentCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _openDetail,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: widget.post.imageUrl != null
              ? _ImageThumbnail(post: widget.post, likes: _likes)
              : _TextThumbnail(post: widget.post, likes: _likes),
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final PublicationModel post;
  final int likes;
  const _ImageThumbnail({required this.post, required this.likes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(color: AppColors.primaryLight),
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.primaryLight),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x77000000), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 10,
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '$likes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _TextThumbnail extends StatelessWidget {
  final PublicationModel post;
  final int likes;
  const _TextThumbnail({required this.post, required this.likes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: AppColors.primaryLight,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 12,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$likes',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
