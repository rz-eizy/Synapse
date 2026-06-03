import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
class _Comment {
  final String author;
  final String text;
  final String time;
 
  const _Comment({
    required this.author,
    required this.text,
    required this.time,
  });
}
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
  final List<_Comment> _comments = [];
 
  void _toggleLike() => setState(() {
        _liked = !_liked;
        _likes += _liked ? 1 : -1;
      });
 
  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        postAuthor: widget.name,
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
class _CommentsSheet extends StatefulWidget {
  final String postAuthor;
  final List<_Comment> initialComments;
  final ValueChanged<_Comment> onCommentAdded;
 
  const _CommentsSheet({
    required this.postAuthor,
    required this.initialComments,
    required this.onCommentAdded,
  });
 
  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}
 
class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late List<_Comment> _comments;
  bool _canSend = false;
 
  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
    _controller.addListener(
      () => setState(() => _canSend = _controller.text.trim().isNotEmpty),
    );
  }
 
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
 
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final newComment = _Comment(author: 'Tú', text: text, time: 'ahora');
    setState(() => _comments.add(newComment));
    widget.onCommentAdded(newComment);
    _controller.clear();
  }
 
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
 
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
 
          // Título
          const Text(
            'Comentarios',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const Divider(height: 20, color: Color(0xFFEEE5F5)),
 
          // Lista
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.primaryLight),
                        const SizedBox(height: 12),
                        const Text(
                          'Sé el primero en comentar',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEE5F5)),
                    itemBuilder: (_, i) => _CommentTile(comment: _comments[i]),
                  ),
          ),
 
          // Input
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Añade un comentario...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _canSend
                          ? GestureDetector(
                              onTap: _submit,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Text(
                                  'Publicar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
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

class _CommentTile extends StatelessWidget {
  final _Comment comment;
  const _CommentTile({required this.comment});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              comment.author.isNotEmpty ? comment.author[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.author} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: comment.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.time,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
