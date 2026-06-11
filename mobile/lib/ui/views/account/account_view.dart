import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/comments_sheet.dart';

class _PostPreview {
  final String? imageUrl;
  final String text;
  final int likes;
  final int comments;

  const _PostPreview({
    this.imageUrl,
    required this.text,
    this.likes = 0,
    this.comments = 0,
  });
}

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  static const List<_PostPreview> _posts = [
    _PostPreview(
      imageUrl: 'https://picsum.photos/seed/p1/300/300',
      text: 'Una imagen del día, que preciosoooo',
      likes: 12,
      comments: 3,
    ),
    _PostPreview(
      text: '¡Feliz fin de semana! Que Diosito los bendiga hoy y siempre. Un abracito virtual 🤗 #Appoyo #Amor',
      likes: 45,
      comments: 2,
    ),
    _PostPreview(
      imageUrl: 'https://picsum.photos/seed/p3/300/300',
      text: 'Reflexión del día, compartan!',
      likes: 24,
      comments: 5,
    ),
    _PostPreview(
      text: 'Busco ayuda para resolver unas dudas, alguien que pueda orientarme? #Comunidad',
      likes: 4,
      comments: 7,
    ),
    _PostPreview(
      imageUrl: 'https://picsum.photos/seed/p5/300/300',
      text: 'Momentos especiales',
      likes: 31,
      comments: 9,
    ),
    _PostPreview(
      text: 'Hola a todos, me presento. Soy nuevo en la comunidad y estoy muy contento de estar aquí 😊 #BuenosDías',
      likes: 79,
      comments: 4,
    ),
    _PostPreview(
      imageUrl: 'https://picsum.photos/seed/p7/300/300',
      text: 'Tarde de trabajo',
      likes: 32,
      comments: 1,
    ),
    _PostPreview(
      text: 'Recordatorio: cuidar tu salud mental es tan importante como cuidar tu salud física 💜 #SaludMental',
      likes: 45,
      comments: 11,
    ),
    _PostPreview(
      imageUrl: 'https://picsum.photos/seed/p9/300/300',
      text: 'Naturaleza y paz',
      likes: 17,
      comments: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ProfileHeader()),
          const SliverToBoxAdapter(
            child: Divider(height: 1, color: Color(0xFFEEE5F5)),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_on, color: AppColors.primary, size: 22),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1, color: Color(0xFFEEE5F5)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(2),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _PostThumbnail(post: _posts[i]),
                childCount: _posts.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryMedium, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, size: 52, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'juan pedro pérez',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            '@jpperez1234',
            style: TextStyle(fontSize: 14, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'hola amigoss, soy Juan Pedro, pueden llamarme JP, soy padre de un precioso hijo de 7 añitos, llamado Mateo, diagnosticado con Trastorno del espectro autista. 💜',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      '9',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Publicaciones',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                      side: const BorderSide(color: AppColors.primaryMedium, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {},
                    child: const Text('Editar perfil'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostThumbnail extends StatefulWidget {
  final _PostPreview post;
  const _PostThumbnail({required this.post});

  @override
  State<_PostThumbnail> createState() => _PostThumbnailState();
}

class _PostThumbnailState extends State<_PostThumbnail> {
  late int _likes;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
    _commentCount = widget.post.comments;
  }

  void _openDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostDetailSheet(
        post: widget.post,
        initialLikes: _likes,
        initialCommentCount: _commentCount,
        onLikeChanged: (val) => setState(() => _likes = val),
        onCommentAdded: () => setState(() => _commentCount++),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openDetail,
      child: widget.post.imageUrl != null
          ? _ImageThumbnail(post: widget.post, likes: _likes)
          : _TextThumbnail(post: widget.post, likes: _likes),
    );
  }
}

// miniatura con imagenes ----------------------------
class _ImageThumbnail extends StatelessWidget {
  final _PostPreview post;
  final int likes; 
  const _ImageThumbnail({required this.post, required this.likes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          post.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : Container(color: AppColors.primaryLight),
          errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
        ),
        Positioned(
          bottom: 6,
          left: 6,
          child: Row(
            children: [
              const Icon(Icons.favorite, size: 13, color: Colors.white),
              const SizedBox(width: 3),
              Text(
                '$likes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// miniatura de texto -----------------------------
class _TextThumbnail extends StatelessWidget {
  final _PostPreview post;
  final int likes; 
  const _TextThumbnail({required this.post, required this.likes});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              post.text,
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.4),
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.favorite, size: 12, color: AppColors.primary),
              const SizedBox(width: 3),
              Text(
                '$likes',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostDetailSheet extends StatefulWidget {
  final _PostPreview post;
  final int initialLikes;
  final int initialCommentCount;
  final ValueChanged<int> onLikeChanged;   
  final VoidCallback onCommentAdded;    

  const _PostDetailSheet({
    required this.post,
    required this.initialLikes,
    required this.initialCommentCount,
    required this.onLikeChanged,
    required this.onCommentAdded,
  });

  @override
  State<_PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends State<_PostDetailSheet> {
  late int _likes;
  bool _liked = false;
  late List<AppComment> _comments;

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes;
    _comments = List.generate(
      widget.initialCommentCount,
      (i) => AppComment(
        author: 'Usuario ${i + 1}',
        text: 'Comentario de ejemplo ${i + 1}',
        time: 'hace ${i + 1}h',
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    widget.onLikeChanged(_likes); 
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialComments: _comments,
        onCommentAdded: (String textContent) async {
          final newComment = AppComment(
            author: 'Tú', 
            text: textContent, 
            time: 'ahora'
          );
          setState(() {_comments.add(newComment); });
          return true;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle ------------------------
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

          // Imagen -----------------------
          if (widget.post.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.post.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Texto ---------------------------
          Text(
            widget.post.text,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEE5F5)),
          const SizedBox(height: 12),

          // Acciones
          Row(
            children: [
              // Like con animación -----------------------
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(_liked),
                        size: 22,
                        color: _liked ? Colors.red : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_likes',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Comentarios -----------------
              GestureDetector(
                onTap: _openComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 22, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '${_comments.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}