import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/models.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_snackbar.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PostService _postService = PostService();
  final ProfileService _profileService = ProfileService();

  int _selectedCategoryIndex = 0;
  List<CatUser> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounceTimer;

  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  bool _isSeeding = false;
  String? _postsError;

  final List<String> _categories = [
    'Trending',
    'Reels',
    'Ragdoll',
    'Funny Cats',
    'Kittens',
    'Cat Naps',
    'Snacks & Treats',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool _hasAttemptedAutoSeed = false;

  Future<void> _loadPosts({bool isRefresh = false}) async {
    if (!mounted) return;
    if (!isRefresh) {
      setState(() {
        _isLoadingPosts = true;
        _postsError = null;
      });
    }

    try {
      final fetched = await _postService.getPublicFeed(page: 1, pageSize: 50);
      if (mounted) {
        setState(() {
          _posts = fetched;
          _isLoadingPosts = false;
          _postsError = null;
        });

        // Only auto-seed once if feed is completely empty
        if (fetched.isEmpty && !_hasAttemptedAutoSeed) {
          _hasAttemptedAutoSeed = true;
          _seedAndReload();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
          _postsError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _seedAndReload() async {
    if (_isSeeding || !mounted) return;
    setState(() {
      _isSeeding = true;
    });

    try {
      await _postService.seedMockData();
      if (mounted) {
        AppSnackBar.success(context, 'Demo cats and posts generated successfully!');
        final fetched = await _postService.getPublicFeed(page: 1, pageSize: 50);
        setState(() {
          _posts = fetched;
          _isSeeding = false;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSeeding = false;
          _isLoadingPosts = false;
        });
        AppSnackBar.error(context, 'Seeding failed: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  List<Post> get _filteredPosts {
    if (_posts.isEmpty) return [];

    final category = _categories[_selectedCategoryIndex].toLowerCase();
    if (category == 'trending') {
      final sorted = List<Post>.from(_posts);
      sorted.sort((a, b) => b.likesCount.compareTo(a.likesCount));
      return sorted;
    }

    if (category == 'reels') {
      final matched = _posts.where((p) {
        final cap = p.caption.toLowerCase();
        return cap.contains('#reel') || cap.contains('reel');
      }).toList();
      return matched.isNotEmpty ? matched : _posts;
    }

    // Filter by category keyword in caption, breed, user category
    final matched = _posts.where((p) {
      final cap = p.caption.toLowerCase();
      final userCat = p.user.category.toLowerCase();
      final query = category.replaceAll('&', '').replaceAll('  ', ' ').trim();
      final tokens = query.split(' ').where((t) => t.isNotEmpty);

      for (final t in tokens) {
        if (cap.contains(t) || userCat.contains(t)) return true;
      }
      return false;
    }).toList();

    return matched.isNotEmpty ? matched : _posts;
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      try {
        final results = await _profileService.searchUsers(trimmed);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchError = e.toString().replaceAll('Exception: ', '');
          });
        }
      }
    });
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _searchError!,
            style: AppTypography.bodyRegular.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.borderMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No cats or users found for "${_searchController.text.trim()}"',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 72,
        color: AppColors.borderSubtle,
      ),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surfaceSecondary,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? const Icon(Icons.pets, color: AppColors.primary, size: 24)
                : null,
          ),
          title: Row(
            children: [
              Text(
                user.username,
                style: AppTypography.bodyBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  size: 15,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
          subtitle: Text(
            user.displayName.isNotEmpty
                ? '${user.displayName} • ${user.followersCount} followers'
                : '${user.followersCount} followers',
            style: AppTypography.captionTimestamp.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: user),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMasonryCard(Post post, int index, List<Post> currentList) {
    final imageUrl = post.imageUrls.isNotEmpty
        ? post.imageUrls.first
        : '';
    final isMultiImage = post.imageUrls.length > 1;
    final isReel = post.caption.toLowerCase().contains('#reel') || index % 5 == 2;

    // Staggered aspect ratios for Pinterest/Instagram style masonry layout
    final aspectRatios = [1.1, 0.82, 1.25, 0.9, 1.3, 0.85];
    final cardAspectRatio = aspectRatios[index % aspectRatios.length];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              posts: currentList,
              initialIndex: index,
              title: 'Explore',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Post Image with dynamic aspect ratio
            AspectRatio(
              aspectRatio: cardAspectRatio,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceSecondary,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceSecondary,
                        child: const Icon(
                          Icons.pets_rounded,
                          color: AppColors.borderMuted,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceSecondary,
                      child: const Icon(
                        Icons.pets_rounded,
                        color: AppColors.borderMuted,
                        size: 32,
                      ),
                    ),
            ),

            // Top Badges (Multi-photo or Reel indicator)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isReel)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else if (isMultiImage)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.collections_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Gradient & Meta Information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Author mini avatar
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white24,
                      backgroundImage: post.user.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(post.user.avatarUrl)
                          : null,
                      child: post.user.avatarUrl.isEmpty
                          ? const Icon(Icons.pets, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 5),
                    // Username
                    Expanded(
                      child: Text(
                        post.user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 3),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Like Count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 12,
                          color: post.isLiked ? Colors.redAccent : Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${post.likesCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildMasonryBody() {
    if (_isLoadingPosts && _posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_postsError != null && _posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                _postsError!,
                style: AppTypography.bodyRegular.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadPosts(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentPosts = _filteredPosts;

    if (currentPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.pets_rounded,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No cat posts available yet',
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate adorable mock cats, high quality photos, and likes/comments with one tap!',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSeeding ? null : _seedAndReload,
                icon: _isSeeding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(_isSeeding ? 'Generating cats...' : 'Generate Demo Cats & Posts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadPosts(isRefresh: true),
      child: MasonryGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: currentPosts.length,
        itemBuilder: (context, index) {
          final post = currentPosts[index];
          return _buildMasonryCard(post, index, currentPosts);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearchingMode = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceTertiary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  style: AppTypography.bodyRegular.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    hintText: 'Search cats, breeds, #hashtags...',
                    hintStyle: AppTypography.bodySm.copyWith(
                      color: AppColors.textPlaceholder,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.clear,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottom: isSearchingMode
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Column(
                  children: [
                    // Category Filter Pills Tray
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                                  width: 0.8,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _categories[index],
                                  style: AppTypography.labelSm.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 0.8, color: AppColors.borderSubtle),
                  ],
                ),
              ),
      ),
      body: isSearchingMode ? _buildSearchResults() : _buildMasonryBody(),
    );
  }
}
