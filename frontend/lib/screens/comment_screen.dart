import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/comment_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_snackbar.dart';

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Comment> _comments = [];
  bool _canPost = false;
  bool _isLoading = true;
  bool _isPosting = false;
  String? _loadError;
  late int _commentCount;

  CatUser get _currentUser =>
      AuthService().currentUser ??
      AuthService().lastUser ??
      const CatUser(
        id: '',
        username: 'you',
        displayName: 'You',
        avatarUrl: '',
      );

  @override
  void initState() {
    super.initState();
    _commentCount = widget.post.commentsCount;
    _commentInputController.addListener(() {
      final canPost = _commentInputController.text.trim().isNotEmpty;
      if (canPost != _canPost) {
        setState(() {
          _canPost = canPost;
        });
      }
    });
    _loadComments();
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final result = await CommentService().listComments(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments
          ..clear()
          ..addAll(result.comments);
        _commentCount = result.commentCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onPostTapped() async {
    final text = _commentInputController.text.trim();
    if (text.isEmpty || _isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final result = await CommentService().createComment(
        postDocumentId: widget.post.id,
        text: text,
      );
      if (!mounted) return;
      setState(() {
        _comments.add(result.comment);
        _commentCount = result.commentCount;
        _isPosting = false;
        _canPost = false;
      });
      _commentInputController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPosting = false;
      });
      AppSnackBar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _confirmDelete(Comment comment) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Delete Comment?',
      message: 'Are you sure you want to delete this comment?',
      icon: Icons.delete_outline,
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      final count = await CommentService().deleteComment(comment.id);
      if (!mounted) return;
      setState(() {
        _comments.removeWhere((c) => c.id == comment.id);
        _commentCount = count;
      });
      AppSnackBar.success(context, 'Comment deleted');
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  bool _isOwnComment(Comment comment) {
    final current = AuthService().currentUser;
    if (current == null) return false;
    return comment.user.id == current.id ||
        comment.user.username == current.username;
  }

  void _popWithCount() {
    Navigator.of(context).pop(_commentCount);
  }

  Widget _buildCommentRow(Comment comment) {
    final avatar = comment.user.avatarUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.storyGradient45,
            ),
            child: ClipOval(
              child: avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceTertiary,
                        child: const Icon(Icons.pets, size: 16, color: AppColors.primary),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceTertiary,
                      child: const Icon(Icons.pets, size: 16, color: AppColors.primary),
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
                        text: '${comment.user.username} ',
                        style: AppTypography.bodyBold,
                      ),
                      TextSpan(
                        text: comment.text,
                        style: AppTypography.bodyRegular,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(comment.timestamp, style: AppTypography.captionTimestamp),
              ],
            ),
          ),
          if (_isOwnComment(comment))
            IconButton(
              icon: const Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
              visualDensity: VisualDensity.compact,
              onPressed: () => _confirmDelete(comment),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithCount();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textPrimary),
            onPressed: _popWithCount,
          ),
          title: Text('Comments', style: AppTypography.headlineMd),
          centerTitle: true,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0.8),
            child: Divider(height: 0.8, color: AppColors.borderSubtle),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadComments,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.storyGradient45,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              widget.post.user.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.surfaceTertiary,
                                child: const Icon(Icons.pets, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${widget.post.user.username} ',
                                      style: AppTypography.bodyBold,
                                    ),
                                    TextSpan(
                                      text: widget.post.caption,
                                      style: AppTypography.bodyRegular,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(widget.post.timestamp, style: AppTypography.captionTimestamp),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: AppColors.borderMuted,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Original Post',
                                    style: AppTypography.captionTimestamp.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 0.8, color: AppColors.borderSubtle),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              'Could not load comments',
                              style: AppTypography.headlineMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _loadError!,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textPlaceholder,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _loadComments,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      )
                    else if (_comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: AppColors.primary.withValues(alpha: 0.45),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No comments yet',
                              style: AppTypography.headlineMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to share a thought about this cat post.',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textPlaceholder,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ..._comments.map(_buildCommentRow),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceCanvas,
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 0.8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: SafeArea(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.surfaceTertiary,
                      backgroundImage: _currentUser.avatarUrl.isNotEmpty
                          ? NetworkImage(_currentUser.avatarUrl)
                          : null,
                      child: _currentUser.avatarUrl.isEmpty
                          ? const Icon(Icons.pets, size: 16, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTertiary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _commentInputController,
                          enabled: !_isPosting,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: AppTypography.bodySm.copyWith(
                              color: AppColors.textPlaceholder,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: AppTypography.bodyRegular,
                          onSubmitted: (_) => _onPostTapped(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: (_canPost && !_isPosting) ? _onPostTapped : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        child: _isPosting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Text(
                                'Post',
                                style: AppTypography.bodyBold.copyWith(
                                  color: _canPost
                                      ? AppColors.primary
                                      : AppColors.textPlaceholder,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
