import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/comments_sheet.dart';
class ProfessionalCard extends StatefulWidget {
  final String name;
  final String handle;
  final String profession;
  final String imageUrl;
  final String date;
  final String description;
  final List<String> hashtags;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.handle,
    required this.profession,
    required this.imageUrl,
    required this.date,
    required this.description,
    this.hashtags = const [],
  });

 @override
  State<ProfessionalCard> createState() => _ProfessionalCardState();
}

class _ProfessionalCardState extends State<ProfessionalCard> {
  int _likes = 0;
  bool _liked = false;
  final List<AppComment> _comments = [];
 
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
        onCommentAdded: (String textContent) async{
          final newComment = AppComment(
            author: 'Tú',
            text: textContent,
            time: 'ahora',
          );
          
          setState(() {
            _comments.add(newComment);
          });
          return true;
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
          // header ------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: widget.imageUrl.isNotEmpty
                    ? NetworkImage(widget.imageUrl)
                    : null,
                child: widget.imageUrl.isEmpty
                    ? Text(
                        widget.name.isNotEmpty ? widget.name[0] : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.handle,
                      style: const TextStyle(fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Text(
                widget.date,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
 
          // descripción ---------------
          Text(
            widget.description,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),
 
          // hashtags --------------------
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
 
          // acciones ------------------
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
