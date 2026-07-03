import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/comments_sheet.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/commentService.dart';
import '../../core/models/commentModel.dart';
import '../../core/services/publicationService.dart';
import '../../core/services/reportService.dart';

class CommunityCard extends StatefulWidget {
  final String? id;
  final String userName;
  final String userImageUrl;
  final String date;
  final String content;
  final List<String> hashtags;
  final int commentCount;
  final int likeCount;
  final String? postImageUrl;

  const CommunityCard({
    super.key,
    this.id,
    required this.userName,
    required this.userImageUrl,
    required this.date,
    required this.content,
    this.hashtags = const [],
    this.commentCount = 0,
    this.likeCount = 0,
    this.postImageUrl,
  });

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  late int _likes;
  bool _liked = false;
  late int _commentCountLocal;

  final _storage            = const FlutterSecureStorage();
  final _commentApiService  = CommentApiService();
  final _apiService         = PublicationApiService();

  @override
  void initState() {
    super.initState();
    _likes              = widget.likeCount;
    _commentCountLocal  = widget.commentCount;
  }

  Future<void> _toggleLike() async {
    final bool next = !_liked;
    setState(() {
      _liked  = next;
      _likes += next ? 1 : -1;
    });

    final String token         = await _storage.read(key: 'jwt_token') ?? '';
    final String publicationId = widget.id ?? '';
    if (token.isEmpty || publicationId.isEmpty) return;

    bool success = await _apiService.toggleLike(token, publicationId, next);
    if (!success) {
      setState(() {
        _liked  = !_liked;
        _likes += _liked ? 1 : -1;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de red: No se pudo registrar el like.')),
      );
    }
  }

  Future<void> _openComments() async {
    final String token         = await _storage.read(key: 'jwt_token') ?? '';
    final String publicationId = widget.id ?? '';

    if (token.isEmpty || publicationId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión inválida o error de publicación.')),
      );
      return;
    }

    List<CommentModel> serverComments = [];
    try {
      serverComments = await _commentApiService.fetchComments(token, publicationId);
    } catch (e) {
      debugPrint('Error al descargar comentarios: $e');
    }

    final List<AppComment> uiComments = serverComments.map((c) {
      return AppComment(
        id: c.id,
        author: c.authorName,
        text: c.content,
        time: 'hace poco',
        imageUrl: c.authorImageUrl,
      );
    }).toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CommentsSheet(
        initialComments: uiComments,
        onCommentAdded: (String textComent) async {
          bool isSaved = await _commentApiService.addComment(
            token, publicationId, textComent,
          );
          if (isSaved) {
            setState(() => _commentCountLocal++);
          }
          return isSaved;
        },
      ),
    );
  }

  bool _isHidden = false;

  void _openReportSheet() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PublicationReportDialog(
        publicationAuthor: widget.userName,
        publicationPreview: widget.content,
        publicationId: widget.id ?? '',
      ),
    );
    if (result == true) {
      setState(() {
        _isHidden = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isHidden) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _UserAvatar(
                  name: widget.userName,
                  imageUrl: widget.userImageUrl,
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Menú 3 puntos
                SizedBox(
                  width: 36,
                  height: 36,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz,
                        size: 20, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    onSelected: (value) {
                      if (value == 'report') _openReportSheet();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: const [
                            Icon(Icons.flag_outlined,
                                size: 16, color: AppColors.error),
                            SizedBox(width: 10),
                            Text(
                              'Reportar publicación',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Contenido ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              widget.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // ── Imagen ──────────────────────────────────────────────────────
          if (widget.postImageUrl != null &&
              widget.postImageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  widget.postImageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],

          // ── Hashtags ────────────────────────────────────────────────────
          if (widget.hashtags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.hashtags
                    .map((tag) => Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],

          // ── Separador ───────────────────────────────────────────────────
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),

          // ── Acciones ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Comentarios
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: _commentCountLocal,
                  onTap: _openComments,
                ),
                // Likes
                _LikeButton(
                  liked: _liked,
                  count: _likes,
                  onTap: _toggleLike,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double radius;

  const _UserAvatar({
    required this.name,
    required this.imageUrl,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child: imageUrl.isEmpty
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: radius * 0.7,
                ),
              )
            : null,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 23, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final bool liked;
  final int count;
  final VoidCallback onTap;

  const _LikeButton({
    required this.liked,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(liked),
                size: 23,
                color: liked ? const Color(0xFFE74C3C) : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Motivos predefinidos ───────────────────────────────────────────────────────
const List<String> _reportReasons = [
  'Contenido inapropiado',
  'Acoso o bullying',
  'Desinformación',
  'Spam o publicidad',
  'Discurso de odio',
  'Otro',
];

// ── Diálogo de reporte ─────────────────────────────────────────────────────────
class _PublicationReportDialog extends StatefulWidget {
  final String publicationAuthor;
  final String publicationPreview;
  final String publicationId;

  const _PublicationReportDialog({
    required this.publicationAuthor,
    required this.publicationPreview,
    required this.publicationId,
  });

  @override
  State<_PublicationReportDialog> createState() =>
      _PublicationReportDialogState();
}

class _PublicationReportDialogState
    extends State<_PublicationReportDialog> {
  String? _selectedReason;
  final _detailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedReason == null || widget.publicationId.isEmpty) return;
    
    // Check token
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) return;
    
    // Cargar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    final apiService = ReportApiService();
    final reportType = ReportApiService.mapUIMotifToReportType(_selectedReason!);
    
    bool success = await apiService.createReport(
      token,
      reportType,
      _detailController.text.trim(),
      idPublication: widget.publicationId,
    );
    
    if (!mounted) return;
    Navigator.pop(context); // close loading
    
    if (success) {
      setState(() => _submitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar el reporte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _SuccessView() : _FormView(),
      ),
    );
  }

  Widget _SuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 16),
        const Text(
          'Reporte enviado',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gracias por ayudarnos a mantener la comunidad segura.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _FormView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flag_outlined,
                  color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Reportar publicación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.publicationAuthor}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: widget.publicationPreview,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Motivo
        const Text(
          'Motivo del reporte',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._reportReasons.map(
          (reason) => GestureDetector(
            onTap: () => setState(() => _selectedReason = reason),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedReason == reason
                    ? AppColors.primaryLight
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedReason == reason
                      ? AppColors.primary
                      : AppColors.divider,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedReason == reason
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: _selectedReason == reason
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (_selectedReason == reason)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Detalle adicional
        TextField(
          controller: _detailController,
          maxLines: 3,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Detalle adicional (opcional)...',
            hintStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Botón enviar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedReason != null
                  ? AppColors.primary
                  : AppColors.divider,
              foregroundColor: _selectedReason != null
                  ? Colors.white
                  : AppColors.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _selectedReason != null ? _submit : null,
            child: const Text('Enviar reporte',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}