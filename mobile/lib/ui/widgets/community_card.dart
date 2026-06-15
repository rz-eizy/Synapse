import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/comments_sheet.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/commentService.dart';
import '../../core/models/commentModel.dart';
import '../../core/services/publicationService.dart';

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
    this.postImageUrl
  });

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  late int _likes;
  bool _liked = false;

  late int _commentCountLocal;
  final _storage = const FlutterSecureStorage();
  final _commentApiService = CommentApiService();
  final _apiService = PublicationApiService();

  @override
  void initState() {
    super.initState();
    _likes = widget.likeCount;
    _commentCountLocal = widget.commentCount;
  }

  Future<void> _toggleLike() async {
    final bool nuevoEstadoLike = !_liked;

    setState(() {
      _liked = nuevoEstadoLike;
      _likes += nuevoEstadoLike ? 1 : -1;
    });

    final String token = await _storage.read(key: 'jwt_token') ?? '';
    final String publicationId = widget.id ?? '';

    if (token.isEmpty || publicationId.isEmpty) return;

    bool success =
        await _apiService.toggleLike(token, publicationId, nuevoEstadoLike);

    if (!success) {
      setState(() {
        _liked = !_liked;
        _likes += _liked ? 1 : -1;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error de red: No se pudo registrar el like.')),
      );
    }
  }

  Future<void> _openComments() async {
    final String token = await _storage.read(key: 'jwt_token') ?? '';
    final String publicationId = widget.id ?? '';

    if (token.isEmpty || publicationId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sesión inválida o error de publicación.')),
      );
      return;
    }

    List<CommentModel> serverComments = [];
    try {
      serverComments =
          await _commentApiService.fetchComments(token, publicationId);
    } catch (e) {
      debugPrint("Error al descargar comentarios: $e");
    }

    List<AppComment> uiComments = serverComments.map((c) {
      return AppComment(
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
            token,
            publicationId,
            textComent,
          );

          if (isSaved) {
            setState(() {
              _commentCountLocal++;
            });
          }
          return isSaved;
        },
      ),
    );
  }

  void _openReportSheet() {
    showDialog(
      context: context,
      builder: (_) => _PublicationReportDialog(
        publicationAuthor: widget.userName,
        publicationPreview: widget.content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: widget.userImageUrl.isNotEmpty
                    ? NetworkImage(widget.userImageUrl)
                    : null,
                child: widget.userImageUrl.isEmpty
                    ? Text(
                        widget.userName.isNotEmpty ? widget.userName[0] : '?',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Botón 3 puntos
              SizedBox(
                width: 32,
                height: 32,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      size: 20, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'report') _openReportSheet();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined,
                              size: 18, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Reportar publicación'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contenido
          Text(
            widget.content,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),

          //Imagenes
          if (widget.postImageUrl != null && widget.postImageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.postImageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink()
              )
            )
          ],

          // Hashtags
          if (widget.hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
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
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                widget.date,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const Spacer(),
              // Comentarios
              GestureDetector(
                onTap: _openComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '$_commentCountLocal',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Likes
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: _liked ? Colors.red : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_likes',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
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

// Motivos predefinidos ----------------------------
const List<String> _reportReasons = [
  'Contenido inapropiado',
  'Acoso o bullying',
  'Desinformación',
  'Spam o publicidad',
  'Discurso de odio',
  'Otro',
];

class _PublicationReportDialog extends StatefulWidget {
  final String publicationAuthor;
  final String publicationPreview;

  const _PublicationReportDialog({
    required this.publicationAuthor,
    required this.publicationPreview,
  });

  @override
  State<_PublicationReportDialog> createState() =>
      _PublicationReportDialogState();
}

class _PublicationReportDialogState extends State<_PublicationReportDialog> {
  String? _selectedReason;
  final _detailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedReason == null) return;
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        const Icon(Icons.check_circle_outline,
            color: AppColors.primary, size: 52),
        const SizedBox(height: 12),
        const Text(
          'Reporte enviado',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gracias por ayudarnos a mantener la comunidad segura.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
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
            const Icon(Icons.flag_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Reportar publicación',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Preview de la publicación
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.publicationAuthor}: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: widget.publicationPreview,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Motivo (lista predefinida)
        const Text(
          'Motivo del reporte',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
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
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedReason == reason
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 1.5,
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
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_selectedReason == reason)
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Detalle adicional
        TextField(
          controller: _detailController,
          maxLines: 3,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Detalle adicional (opcional)...',
            hintStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Botón enviar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedReason != null
                  ? AppColors.primary
                  : AppColors.primaryLight,
              foregroundColor: _selectedReason != null
                  ? Colors.white
                  : AppColors.textMuted,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
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