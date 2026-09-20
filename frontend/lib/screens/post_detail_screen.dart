import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/post_card.dart';
import 'comment_screen.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;
  final String title;

  const PostDetailScreen({
    super.key,
    required this.posts,
    this.initialIndex = 0,
    this.title = 'Posts',
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  ScrollController _scrollController = ScrollController();
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _posts = List.from(widget.posts);
    _scrollController = ScrollController();
    // Jump to the tapped post after build
    if (widget.initialIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Approximate height per post card is ~580px
        final offset = widget.initialIndex * 580.0;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openComments(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentScreen(post: post),
      ),
    );
  }

  void _openEditPost(Post post) async {
    final updated = await Navigator.of(context).push<Post>(
      MaterialPageRoute(
        builder: (context) => EditPostScreen(
          post: post,
          onPostUpdated: (newPost) {
            setState(() {
              post.caption = newPost.caption;
            });
          },
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        post.caption = updated.caption;
      });
    }
  }

  void _showMoreOptions(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCanvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.borderMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  title: Text('Edit Post', style: AppTypography.bodyBold),
                  onTap: () {
                    Navigator.pop(context);
                    _openEditPost(post);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border, color: AppColors.textPrimary),
                  title: Text('Save Post', style: AppTypography.bodyBold),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      post.isSaved = !post.isSaved;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(post.isSaved ? 'Saved to collection!' : 'Removed from saved.'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                  title: Text('Share to...', style: AppTypography.bodyBold),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.link, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Post link copied!'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.borderSubtle),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.interactiveLike),
                  title: Text(
                    'Delete Post',
                    style: AppTypography.bodyBold.copyWith(color: AppColors.interactiveLike),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _posts.removeWhere((p) => p.id == post.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Post deleted'),
                          ],
                        ),
                      ),
                    );
                    if (_posts.isEmpty) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
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
          widget.title,
          style: AppTypography.headlineMd,
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.8),
          child: Divider(height: 0.8, color: AppColors.borderSubtle),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCard(
            post: post,
            onCommentTap: () => _openComments(post),
            onMoreTap: () => _showMoreOptions(post),
          );
        },
      ),
    );
  }
}
