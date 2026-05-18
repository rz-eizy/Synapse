import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommunityCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header -------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(userImageUrl),
                backgroundColor: AppColors.primaryLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12.64, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // contenido publicación
          Text(
            content,
            style: const TextStyle(
              fontSize: 14.22,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          // hashtags --------------
          if(hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: hashtags
                  .map(
                    (tag) => Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 14.22,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 12),

          // acciones -------------
          Row(
            children: [
              _ActionButton(icon: Icons.chat_bubble_outline, count: commentCount),
              const SizedBox(width: 16),
              _ActionButton(icon: Icons.favorite_border, count: likeCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;

  const _ActionButton({required this.icon, required this.count});

  @override
  Widget build(BuildContext content) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}




