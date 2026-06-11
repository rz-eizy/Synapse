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

    if (token.isEmpty || publicationId.isEmpty) {
      return;
    }

    bool success = await _apiService.toggleLike(token, publicationId, nuevoEstadoLike);

    if (!success) {
      setState(() {
        _liked = !_liked;
        _likes += _liked ? 1 : -1;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de red: No se pudo registrar el like.')),
      );
    }
  }

  Future<void> _openComments() async {
    final String token = await _storage.read(key: 'jwt_token') ?? '';
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
      debugPrint("Error al descargar comentarios: $e");
    }

    List<AppComment> uiComments = serverComments.map((c) {
      return AppComment(
        author: c.authorName,
        text: c.content,
        time: 'hace poco', 
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
          // Header -----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
              Text(
                widget.date,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contenido ----------
          Text(
            widget.content,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),

          // Hashtags --------------
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
              GestureDetector(
                onTap: _openComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '$_commentCountLocal',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
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
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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