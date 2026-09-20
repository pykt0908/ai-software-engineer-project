import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_snackbar.dart';
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
  // Stories remain a visual MVP placeholder (out of scope per spec).
  late List<Story> _stories;
  bool _hasUnreadNotifications = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _stories = _buildPlaceholderStories();
    _scrollController.addListener(_onScroll);
    AuthService().currentUserNotifier.addListener(_onCurrentUserChanged);
    _loadPosts(refresh: true);
    _refreshUnreadBadge();
  }

  Future<void> _refreshUnreadBadge() async {
    try {
      final count = await NotificationService().unreadCount();
      if (!mounted) return;
      setState(() => _hasUnreadNotifications = count > 0);
    } catch (_) {
      // Keep prior badge state on failure.
    }
  }

  void _onCurrentUserChanged() {
    if (!mounted) return;
    setState(() {
      _stories = _buildPlaceholderStories();
    });
  }

  /// Self story uses the real logged-in user; peers stay decorative mock chrome.
  List<Story> _buildPlaceholderStories() {
    final self = AuthService().currentUser ?? AuthService().lastUser;
    final peers = MockData.stories.where((s) => !s.isCurrentUser).toList();
    if (self == null) {
      return peers;
    }
    return [
      Story(
        id: 'story_self',
        user: self,
        isCurrentUser: true,
        isViewed: false,
      ),
      ...peers,
    ];
  }

  @override
  void dispose() {
    AuthService().currentUserNotifier.removeListener(_onCurrentUserChanged);
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
      if (refresh) _loadError = null;
    });

    try {
      final List<Post> fetched =
          await PostService().getPublicFeed(page: _currentPage, pageSize: 10);

      if (mounted) {
        setState(() {
          if (refresh) {
            _posts = fetched;
          } else {
            _posts.addAll(fetched);
          }

          if (fetched.length < 10) {
            _hasMore = false;
          } else {
            _currentPage++;
          }
          _isLoading = false;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (refresh) {
            _posts = [];
            _loadError = e.toString().replaceFirst('Exception: ', '');
          }
          _isLoading = false;
        });
      }
    }
  }

  void _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          onUserSelected: widget.onUserSelected,
          onUnreadChanged: _refreshUnreadBadge,
        ),
      ),
    );
    if (mounted) {
      await _refreshUnreadBadge();
    }
  }

  Future<void> _handleRefresh() async {
    await _loadPosts(refresh: true);
  }

  void _openComments(Post post) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (context) => CommentScreen(post: post),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        post.commentsCount = result;
      });
    }
  }

  void _showComingSoon(String feature) {
    AppSnackBar.info(context, '$feature is not available in this MVP.');
  }

  void _showDeleteConfirmation(Post post) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Delete Post?',
      message:
          'Are you sure you want to delete this cat post? This action cannot be undone.',
      icon: Icons.delete_outline,
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await PostService().deletePost(post.id);
      if (mounted) {
        setState(() {
          _posts.removeWhere((p) => p.id == post.id);
        });
        AppSnackBar.success(context, 'Post deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to delete post: $e');
      }
    }
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
                      Navigator.pop(context);
                      try {
                        final res = await ProfileService().toggleFollow(
                          targetDocumentId: post.user.id,
                          currentFollowing: post.user.isFollowing,
                        );
                        if (mounted) {
                          setState(() {
                            for (var i = 0; i < _posts.length; i++) {
                              if (_posts[i].user.id == post.user.id) {
                                final p = _posts[i];
                                _posts[i] = Post(
                                  id: p.id,
                                  user: p.user.copyWith(
                                    isFollowing: res['following'] == true,
                                  ),
                                  imageUrls: p.imageUrls,
                                  imageIds: p.imageIds,
                                  caption: p.caption,
                                  likesCount: p.likesCount,
                                  commentsCount: p.commentsCount,
                                  location: p.location,
                                  taggedUsernames: p.taggedUsernames,
                                  timestamp: p.timestamp,
                                  isLiked: p.isLiked,
                                  isSaved: p.isSaved,
                                );
                              }
                            }
                          });
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        AppSnackBar.error(
                          context,
                          'Follow action failed: $e',
                        );
                      }
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.bookmark_border, color: AppColors.textPrimary),
                  title: Text('Save Post', style: AppTypography.bodyBold),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon('Saved posts');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                  title: Text('Share to...', style: AppTypography.bodyBold),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon('Post sharing');
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

  Widget _buildEmptyOrErrorState() {
    final hasError = _loadError != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              hasError ? Icons.cloud_off_outlined : Icons.pets,
              size: 48,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 12),
            Text(
              hasError ? 'Could not load feed' : 'No cat posts yet!',
              style: AppTypography.headlineMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasError
                  ? _loadError!
                  : 'Be the first to share your adorable kitty moments.',
              style: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
              textAlign: TextAlign.center,
            ),
            if (hasError) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _loadPosts(refresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo_camera_outlined, size: 24, color: AppColors.textPrimary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: () => _showComingSoon('Stories camera'),
            ),
            const SizedBox(width: 10),
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
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 23, color: AppColors.textPrimary),
            splashRadius: 20,
            onPressed: () => _showComingSoon('Direct messages'),
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
            // Stories tray — visual placeholder only (out of MVP scope).
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
                    onTap: () => _showComingSoon('Stories'),
                  );
                },
              ),
            ),
            const Divider(height: 0.8, color: AppColors.borderSubtle),

            if (_posts.isEmpty && !_isLoading)
              _buildEmptyOrErrorState()
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
