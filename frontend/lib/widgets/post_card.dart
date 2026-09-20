import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

import '../services/post_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onCommentTap;
  final VoidCallback? onUserTap;
  final VoidCallback? onMoreTap;

  const PostCard({
    super.key,
    required this.post,
    this.onCommentTap,
    this.onUserTap,
    this.onMoreTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  bool _showBigHeart = false;
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_heartAnimController);
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() async {
    final wasLiked = widget.post.isLiked;
    setState(() {
      if (!wasLiked) {
        widget.post.isLiked = true;
        widget.post.likesCount += 1;
      }
      _showBigHeart = true;
    });
    _heartAnimController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _showBigHeart = false;
        });
      }
    });

    if (!wasLiked) {
      try {
        final res = await PostService().toggleLike(
          postDocumentId: widget.post.id,
          currentLiked: false,
        );
        if (mounted) {
          setState(() {
            widget.post.isLiked = res['liked'] as bool;
            widget.post.likesCount = res['likeCount'] as int;
          });
        }
      } catch (_) {}
    }
  }

  void _toggleLike() async {
    final wasLiked = widget.post.isLiked;
    setState(() {
      if (wasLiked) {
        widget.post.isLiked = false;
        widget.post.likesCount = (widget.post.likesCount - 1).clamp(0, 999999);
      } else {
        widget.post.isLiked = true;
        widget.post.likesCount += 1;
      }
    });

    try {
      final res = await PostService().toggleLike(
        postDocumentId: widget.post.id,
        currentLiked: wasLiked,
      );
      if (mounted) {
        setState(() {
          widget.post.isLiked = res['liked'] as bool;
          widget.post.likesCount = res['likeCount'] as int;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          widget.post.isLiked = wasLiked;
          widget.post.likesCount = wasLiked
              ? widget.post.likesCount + 1
              : (widget.post.likesCount - 1).clamp(0, 999999);
        });
      }
    }
  }

  void _toggleSave() {
    setState(() {
      widget.post.isSaved = !widget.post.isSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      color: AppColors.surfaceCanvas,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header (54px)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // User Avatar with Story Gradient Ring
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.storyGradient45,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceCanvas,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          post.user.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            color: AppColors.surfaceSecondary,
                            child: const Icon(Icons.pets, size: 18, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Username & Location
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onUserTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.user.username,
                              style: AppTypography.bodyBold,
                            ),
                            if (post.user.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: AppColors.primary,
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                        if (post.location.isNotEmpty)
                          Text(
                            post.location,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // More options button
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textPrimary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  onPressed: widget.onMoreTap,
                ),
              ],
            ),
          ),

          // 1:1 Media Canvas
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    color: AppColors.surfaceSecondary,
                    child: PageView.builder(
                      itemCount: post.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          post.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            color: AppColors.surfaceSecondary,
                            child: const Center(
                              child: Icon(Icons.pets, size: 48, color: AppColors.primaryLight),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Multiple Images Badge (e.g. 1/3)
                if (post.imageUrls.length > 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${post.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Big Animated Heart on double tap
                if (_showBigHeart)
                  ScaleTransition(
                    scale: _heartScaleAnimation,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 100,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(post.isLiked),
                      color: post.isLiked ? AppColors.interactiveLike : AppColors.textPrimary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Comment Button
                GestureDetector(
                  onTap: widget.onCommentTap,
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Share Button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.send, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Sharing cute cat post!'),
                          ],
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.send_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Paginator dots for multiple photos
                if (post.imageUrls.length > 1)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      post.imageUrls.length,
                      (index) => Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.borderMuted,
                        ),
                      ),
                    ),
                  ),
                if (post.imageUrls.length > 1) const Spacer(),
                // Bookmark / Save button
                GestureDetector(
                  onTap: _toggleSave,
                  child: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: post.isSaved ? AppColors.primary : AppColors.textPrimary,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),

          // Likes Count & Captions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Likes Count
                Text(
                  '${post.likesCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} likes',
                  style: AppTypography.bodyBold,
                ),
                const SizedBox(height: 4),

                // Rich Caption with Bold username & hashtags
                _buildRichCaption(context, post.user.username, post.caption),
                const SizedBox(height: 4),

                // Comments link
                if (post.commentsCount > 0)
                  GestureDetector(
                    onTap: widget.onCommentTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'View all ${post.commentsCount} comments',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 2),
                // Timestamp
                Text(
                  post.timestamp.toUpperCase(),
                  style: AppTypography.captionTimestamp,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8, color: AppColors.borderSubtle),
        ],
      ),
    );
  }

  Widget _buildRichCaption(BuildContext context, String username, String caption) {
    final words = caption.split(' ');
    final spans = <TextSpan>[
      TextSpan(
        text: '$username ',
        style: AppTypography.bodyBold,
      ),
    ];

    for (final word in words) {
      if (word.startsWith('#')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: AppTypography.bodyRegular,
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
