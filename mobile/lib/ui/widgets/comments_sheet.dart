import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/reportService.dart';

class AppComment {
  final String? id;
  final String author;
  final String text;
  final String time;
  final String? imageUrl;

  const AppComment({
    this.id,
    required this.author,
    required this.text,
    required this.time,
    this.imageUrl,
  });
}

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
  final _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late List<AppComment> _comments;
  bool _canSend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
    _controller.addListener(() {
      final textNotEmpty = _controller.text.trim().isNotEmpty;
      if (textNotEmpty != _canSend) {
        setState(() => _canSend = textNotEmpty && !_isLoading);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _canSend = false;
    });

    final success = await widget.onCommentAdded(text);

    if (!mounted) return;

    if (success) {
      final newComment = AppComment(author: 'Tú', text: text, time: 'ahora');
      setState(() {
        _comments.add(newComment);
        _isLoading = false;
      });
      _controller.clear();
      _focusNode.unfocus();

      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _canSend = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error enviando el comentario. Intente de nuevo.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

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
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 25,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Indicador superior premium estilizado
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Título con contador visualmente integrado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Comentarios',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (_comments.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_comments.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Contenedor Principal de Lista sin divisores agresivos
            Expanded(
              child: _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: AppColors.textMuted.withOpacity(0.3),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Sé el primero en comentar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Comparte tus ideas con el grupo.',
                            style: TextStyle(
                              color: AppColors.textMuted.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _comments.length,
                      itemBuilder: (_, i) => _CommentTile(
                        comment: _comments[i],
                        onReport: () => _showReportDialog(_comments[i]),
                      ),
                    ),
            ),

            // Barra inferior de entrada de texto premium (flotante)
            Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, bottomInset + 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.divider.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submit(),
                        maxLines: 3,
                        minLines: 1,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Añade un comentario...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón enviar con Microanimaciones de Escala
                  AnimatedScale(
                    scale: _canSend ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 150),
                    child: AnimatedOpacity(
                      opacity: _canSend ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 150),
                      child: GestureDetector(
                        onTap: _canSend ? _submit : null,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
  int _likes = 0;
  bool _liked = false;
  bool _showFloatingHeart = false;
  bool _isPressed = false;
  late AnimationController _heartAnim;

  @override
  void initState() {
    super.initState();
    _heartAnim =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 950),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
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
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  void _doubleTapLike() {
    if (!_liked) _toggleLike();
    setState(() => _showFloatingHeart = true);
    _heartAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar =
        widget.comment.imageUrl != null && widget.comment.imageUrl!.isNotEmpty;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1EEFA), width: 1),
        ),
        child: InkWell(
          onDoubleTap: _doubleTapLike,
          onLongPress: widget.onReport,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: hasAvatar
                          ? NetworkImage(widget.comment.imageUrl!)
                          : null,
                      child: !hasAvatar
                          ? const Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.comment.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: AppColors.textMuted.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.comment.time,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.comment.text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4E4B66),
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón de corazón lateral refinado
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                _liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(_liked),
                                size: 15,
                                color: _liked
                                    ? const Color(0xFFE74C3C)
                                    : AppColors.textMuted.withOpacity(0.7),
                              ),
                            ),
                            if (_likes > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                '$_likes',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _liked
                                      ? const Color(0xFFE74C3C)
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Burst effect del Double Tap
                if (_showFloatingHeart)
                  IgnorePointer(
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _heartAnim,
                          curve: const Interval(
                            0.6,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: ScaleTransition(
                        scale:
                            TweenSequence<double>([
                              TweenSequenceItem(
                                tween: Tween<double>(begin: 0.0, end: 1.4),
                                weight: 40,
                              ),
                              TweenSequenceItem(
                                tween: Tween<double>(begin: 1.4, end: 1.0),
                                weight: 30,
                              ),
                              TweenSequenceItem(
                                tween: Tween<double>(begin: 1.0, end: 0.0),
                                weight: 30,
                              ),
                            ]).animate(
                              CurvedAnimation(
                                parent: _heartAnim,
                                curve: Curves.elasticOut,
                              ),
                            ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFE74C3C),
                          size: 44,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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

  void _submit() async {
    if (_selectedReason == null || widget.comment.id == null) return;
    
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
      idComment: widget.comment.id,
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
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _submitted ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Reporte enviado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Revisaremos el contenido para garantizar la seguridad de la comunidad.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_outlined, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Reportar comentario',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
              onPressed: () => Navigator.pop(context),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider.withOpacity(0.3)),
          ),
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(fontSize: 12, height: 1.4),
              children: [
                TextSpan(
                  text: '${widget.comment.author}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: widget.comment.text,
                  style: const TextStyle(color: Color(0xFF4E4B66)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Selecciona el motivo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 210),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: _reportReasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return GestureDetector(
                onTap: () => setState(() => _selectedReason = reason),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight.withOpacity(0.5)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.divider.withOpacity(0.3),
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
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _detailController,
          maxLines: 2,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Detalle adicional (opcional)...',
            hintStyle: TextStyle(
              color: AppColors.textMuted.withOpacity(0.8),
              fontSize: 13,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedReason != null
                  ? AppColors.primary
                  : AppColors.divider.withOpacity(0.6),
              foregroundColor: _selectedReason != null
                  ? Colors.white
                  : AppColors.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _selectedReason != null ? _submit : null,
            child: const Text(
              'Enviar reporte',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
