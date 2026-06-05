import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/comments_sheet.dart';

class CommunityCard extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final String date;
  final String content;
  final List<String> hashtags;
  final int commentCount;
  final int likeCount;

  const CommunityCard({
    super.key,
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
  late List<AppComment> _comments;

  @override
  void initState() {
    super.initState();
    _likes = widget.likeCount;
    // Comentarios de ejemplo pre-cargados
    _comments = List.generate(
      widget.commentCount,
      (i) => AppComment(
        author: 'Usuario $i',
        text: 'Comentario de ejemplo $i',
        time: 'hace 1h',
      ),
    );
  }

  void _toggleLike() => setState(() {
    _liked = !_liked;
    _likes += _liked ? 1 : -1;
  });

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialComments: _comments,
        onCommentAdded: (c) => setState(() => _comments.add(c)),
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
          // header -----------
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
 
          //contenido ----------
          Text(
            widget.content,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),
 
          // hashtags --------------
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
 
          // acciones ----------------
          Row(
            children: [
              // Comentarios
              GestureDetector(
                onTap: _openComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${_comments.length}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // likes
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
 
 
