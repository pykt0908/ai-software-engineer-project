import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/post_card.dart';
import '../widgets/story_avatar.dart';
import 'comment_screen.dart';
import 'edit_post_screen.dart';
import 'notifications_screen.dart';

class FeedScreen extends StatefulWidget {
  final Function(CatUser)? onUserSelected;

  const FeedScreen({super.key, this.onUserSelected});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Post> _posts = [];
  List<Story> _stories = MockData.stories;
  bool _hasUnreadNotifications = true;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final bool _showingFollowingOnly = false;

  @override
  void initState() {
    super.initState();
    _stories = MockData.stories;
    _scrollController.addListener(_onScroll);
    _loadPosts(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoading &&
        _hasMore) {
      _loadPosts(refresh: false);
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Post> fetched = _showingFollowingOnly
          ? await PostService().getFollowingFeed(page: _currentPage, pageSize: 10)
          : await PostService().getPublicFeed(page: _currentPage, pageSize: 10);

      if (mounted) {
        setState(() {
          if (refresh) {
            _posts = fetched;
            if (_posts.isEmpty) {
              // Fallback to mock data if backend has no posts yet
              _posts = List.from(MockData.feedPosts);
            }
          } else {
            _posts.addAll(fetched);
          }

          if (fetched.length < 10) {
            _hasMore = false;
          } else {
            _currentPage++;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (refresh && _posts.isEmpty) {
            _posts = List.from(MockData.feedPosts);
          }
          _isLoading = false;
        });
      }
    }
  }

  void _openNotifications() async {
    setState(() {
      _hasUnreadNotifications = false;
    });
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          onUserSelected: widget.onUserSelected,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadPosts(refresh: true);
  }

  void _openComments(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentScreen(post: post),
      ),
    );
  }

  void _showDeleteConfirmation(Post post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('Are you sure you want to delete this cat post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await PostService().deletePost(post.id);
                if (mounted) {
                  setState(() {
                    _posts.removeWhere((p) => p.id == post.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete post: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showMoreBottomSheet(Post post) {
    final currentUserId = AuthService().currentUser?.id;
    final currentUsername = AuthService().currentUser?.username;
    final isOwnPost = (currentUserId != null && post.user.id == currentUserId) ||
        (currentUsername != null && post.user.username == currentUsername);

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
                if (isOwnPost) ...[
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                    title: Text('Edit Post', style: AppTypography.bodyBold),
                    onTap: () async {
                      Navigator.pop(context);
                      final updated = await Navigator.of(context).push<Post>(
                        MaterialPageRoute(
                          builder: (ctx) => EditPostScreen(post: post),
                        ),
                      );
                      if (updated != null && mounted) {
                        setState(() {
                          final idx = _posts.indexWhere((p) => p.id == updated.id);
                          if (idx != -1) {
                            _posts[idx] = updated;
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text('Delete Post',
                        style: AppTypography.bodyBold.copyWith(color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(post);
                    },
                  ),
                  const Divider(color: AppColors.borderSubtle),
                ] else ...[
                  ListTile(
                    leading: Icon(
                      post.user.isFollowing ? Icons.person_remove_outlined : Icons.person_add_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      post.user.isFollowing ? 'Unfollow @${post.user.username}' : 'Follow @${post.user.username}',
                      style: AppTypography.bodyBold.copyWith(color: AppColors.primary),
                    ),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      try {
                        final res = await ProfileService().toggleFollow(
                          targetDocumentId: post.user.id,
                          currentFollowing: post.user.isFollowing,
                        );
                        if (mounted) {
                          setState(() {
                            for (var p in _posts) {
                              if (p.user.id == post.user.id) {
                                p.user.copyWith(isFollowing: res['following'] as bool);
                              }
                            }
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Follow action failed: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
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
                        duration: const Duration(seconds: 1),
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
                            Text('Link copied to clipboard!'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link, color: AppColors.textPrimary),
                  title: Text('Copy link', style: AppTypography.bodyBold),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(color: AppColors.borderSubtle),
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: AppColors.interactiveLike),
                  title: Text('Report', style: AppTypography.bodyBold.copyWith(color: AppColors.interactiveLike)),
                  onTap: () => Navigator.pop(context),
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
        titleSpacing: 14,
        title: Row(
          children: [
            // Camera icon
            IconButton(
              icon: const Icon(Icons.photo_camera_outlined, size: 24, color: AppColors.textPrimary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.photo_camera, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Cat camera opened!'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            // InstaCat Brand Wordmark & Logo
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/InstaCat-Logo.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 7),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Insta',
                          style: AppTypography.brandTitle.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 21,
                          ),
                        ),
                        Text(
                          'Cat',
                          style: AppTypography.brandTitle.copyWith(
                            color: AppColors.primary,
                            fontSize: 21,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'THE PURR-FECT PET COMMUNITY',
                      style: AppTypography.captionTimestamp.copyWith(
                        color: AppColors.primary,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notifications with Orange Badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 24, color: AppColors.textPrimary),
                splashRadius: 20,
                onPressed: _openNotifications,
              ),
              if (_hasUnreadNotifications)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // Direct Messages
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 23, color: AppColors.textPrimary),
            splashRadius: 20,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Meow Direct Messages'),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.8),
          child: Divider(height: 0.8, color: AppColors.borderSubtle),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _handleRefresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            // 96px Horizontal Stories Tray
            Container(
              height: 96,
              color: AppColors.surfaceCanvas,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: _stories.length,
                itemBuilder: (context, index) {
                  final story = _stories[index];
                  return StoryAvatar(
                    story: story,
                    onTap: () {
                      if (story.isCurrentUser) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Add to Your Story'),
                              ],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.play_circle_outline, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text('Viewing ${story.user.username}\'s story'),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(height: 0.8, color: AppColors.borderSubtle),

            // Posts Stream
            if (_posts.isEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.pets, size: 48, color: AppColors.primaryLight),
                      const SizedBox(height: 12),
                      Text(
                        'No cat posts yet!',
                        style: AppTypography.headlineMd.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Be the first to share your adorable kitty moments.',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._posts.map(
                (post) => PostCard(
                  post: post,
                  onCommentTap: () => _openComments(post),
                  onUserTap: () => widget.onUserSelected?.call(post.user),
                  onMoreTap: () => _showMoreBottomSheet(post),
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
