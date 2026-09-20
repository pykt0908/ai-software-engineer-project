import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentInputController = TextEditingController();
  List<Comment> _comments = MockData.postComments;
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(MockData.postComments);
    _commentInputController.addListener(() {
      final canPost = _commentInputController.text.trim().isNotEmpty;
      if (canPost != _canPost) {
        setState(() {
          _canPost = canPost;
        });
      }
    });
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    super.dispose();
  }

  void _postComment() {
    final text = _commentInputController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      user: MockData.currentUser,
      text: text,
      timestamp: 'Just now',
      likesCount: 0,
      isLiked: false,
    );

    setState(() {
      _comments.add(newComment);
      _commentInputController.clear();
      _canPost = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Comment posted!'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Comments',
          style: AppTypography.headlineMd,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 22, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Share comments sheet'),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.8),
          child: Divider(height: 0.8, color: AppColors.borderSubtle),
        ),
      ),
      body: Column(
        children: [
          // Comments list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              children: [
                // 1. Pinned Original Post Caption
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
                                if (widget.post.user.isVerified)
                                  const WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(Icons.verified, size: 14, color: AppColors.primary),
                                    ),
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
                              Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.borderMuted, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text('Original Post', style: AppTypography.captionTimestamp.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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

                // 2. Comments Conversation Feed
                ..._comments.map((comment) => _buildCommentItem(comment)),
              ],
            ),
          ),

          // 3. Floating Bottom Comment Bar
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
                    backgroundImage: NetworkImage(MockData.currentUser.avatarUrl),
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
                        decoration: InputDecoration(
                          hintText: 'Add a purr-fect comment...',
                          hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.bodyRegular,
                        onSubmitted: (_) => _postComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _canPost ? _postComment : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Text(
                        'Post',
                        style: AppTypography.bodyBold.copyWith(
                          color: _canPost ? AppColors.primary : AppColors.textPlaceholder,
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
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.user.avatarUrl),
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
                    Row(
                      children: [
                        Text(comment.timestamp, style: AppTypography.captionTimestamp),
                        const SizedBox(width: 12),
                        if (comment.likesCount > 0)
                          Text('${comment.likesCount} likes', style: AppTypography.captionTimestamp.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _commentInputController.text = '@${comment.user.username} ';
                          },
                          child: Text(
                            'Reply',
                            style: AppTypography.captionTimestamp.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    comment.isLiked = !comment.isLiked;
                    if (comment.isLiked) {
                      comment.likesCount += 1;
                    } else {
                      comment.likesCount -= 1;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    comment.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: comment.isLiked ? AppColors.interactiveLike : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          // Nested replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 8),
              child: Column(
                children: comment.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(reply.user.avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${reply.user.username} ',
                                      style: AppTypography.bodyBold.copyWith(fontSize: 13),
                                    ),
                                    TextSpan(
                                      text: reply.text,
                                      style: AppTypography.bodyRegular.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(reply.timestamp, style: AppTypography.captionTimestamp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
