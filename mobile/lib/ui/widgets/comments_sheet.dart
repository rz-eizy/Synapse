import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppComment {
  final String author;
  final String text;
  final String time;

  const AppComment({
    required this.author,
    required this.text,
    required this.time,
  });
}

// Motivos predefinidos de reporte
const List<String> _reportReasons = [
  'Contenido inapropiado',
  'Acoso o bullying',
  'Desinformación',
  'Spam o publicidad',
  'Discurso de odio',
  'Otro',
];

class CommentsSheet extends StatefulWidget {
  final List<AppComment> initialComments;
  final Future<bool> Function(String content) onCommentAdded;

  const CommentsSheet({
    super.key,
    required this.initialComments,
    required this.onCommentAdded,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();
  late List<AppComment> _comments;
  bool _canSend   = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
    _controller.addListener(
      () => setState(
        () => _canSend = _controller.text.trim().isNotEmpty && !_isLoading,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _canSend   = false;
    });

    final success = await widget.onCommentAdded(text);

    if (!mounted) return;

    if (success) {
      final c = AppComment(author: 'Tú', text: text, time: 'ahora');
      setState(() {
        _comments.add(c);
        _isLoading = false;
      });
      _controller.clear();
      _focusNode.unfocus();
    } else {
      setState(() {
        _isLoading = false;
        _canSend   = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error enviando el comentario. Intente de nuevo.')),
      );
    }
  }

  // Reporte --------------------- 
  void _showReportDialog(AppComment comment) {
    showDialog(
      context: context,
      builder: (_) => _ReportDialog(comment: comment),
    );
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
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Título
          const Text(
            'Comentarios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 20, color: Color(0xFFEEE5F5)),

          // Lista ----------------
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: AppColors.primaryLight),
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
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFEEE5F5)),
                    itemBuilder: (_, i) => _CommentTile(
                      comment: _comments[i],
                      onReport: () => _showReportDialog(_comments[i]),
                    ),
                  ),
          ),

          // Input ----------------
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.newline,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Añade un comentario...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón enviar
                AnimatedOpacity(
                  opacity: _canSend ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _canSend ? _submit : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
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

class _CommentTile extends StatefulWidget {
  final AppComment comment;
  final VoidCallback onReport;

  const _CommentTile({required this.comment, required this.onReport});

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile>
    with SingleTickerProviderStateMixin {
  int  _likes = 0;
  bool _liked = false;

  // Animación del corazón flotante al hacer doble tap ------------
  late AnimationController _heartAnim;
  bool _showFloatingHeart = false;

  @override
  void initState() {
    super.initState();
    _heartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _showFloatingHeart = false);
          _heartAnim.reset();
        }
      });
  }

  @override
  void dispose() {
    _heartAnim.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked  = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  void _doubleTapLike() {
    if (!_liked) _toggleLike();
    // Muestra corazón flotante animado --------
    setState(() => _showFloatingHeart = true);
    _heartAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _doubleTapLike,
      onLongPress: widget.onReport,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    widget.comment.author.isNotEmpty
                        ? widget.comment.author[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Texto + timestamp -----------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${widget.comment.author} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: widget.comment.text,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            widget.comment.time,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 12),
                          // Hint de long press para reporte
                          const Text(
                            'Mantén para reportar',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón de like ------------
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _liked ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(_liked),
                          size: 16,
                          color: _liked ? Colors.red : AppColors.textMuted,
                        ),
                      ),
                      if (_likes > 0)
                        Text(
                          '$_likes',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Corazón flotante animado (doble tap) -------------
            if (_showFloatingHeart)
              Positioned.fill(
                child: Center(
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0).animate(
                      CurvedAnimation(
                          parent: _heartAnim, curve: Curves.easeOut),
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.6).animate(
                        CurvedAnimation(
                            parent: _heartAnim, curve: Curves.elasticOut),
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.red, size: 60),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportDialog extends StatefulWidget {
  final AppComment comment;
  const _ReportDialog({required this.comment});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
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

  // Vista de éxito ---------------------
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
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ),
      ],
    );
  }

  // Formulario de reporte ------------------------
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
              'Reportar comentario',
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

        // Comentario reportado (preview)
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
                  text: '${widget.comment.author}: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
                TextSpan(
                  text: widget.comment.text,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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

        // Botón enviar reporte
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