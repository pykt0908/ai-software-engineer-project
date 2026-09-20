import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_snackbar.dart';
import 'profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  List<CatUser> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounceTimer;

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
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
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
        final results = await ProfileService().searchUsers(trimmed);
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
                ? NetworkImage(user.avatarUrl)
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

  @override
  Widget build(BuildContext context) {
    final images = MockData.exploreImages;
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
      body: isSearchingMode
          ? _buildSearchResults()
          : GridView.builder(
              padding: const EdgeInsets.all(1.5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.5,
                mainAxisSpacing: 1.5,
                childAspectRatio: 1.0,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index];
                final isReel = index % 3 == 0;
                final isMulti = index % 4 == 0;

                return GestureDetector(
                  onTap: () {
                    AppSnackBar.info(
                      context,
                      'Explore media grid is a visual placeholder (outside MVP).',
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          color: AppColors.surfaceSecondary,
                          child: const Icon(Icons.pets, color: AppColors.borderMuted),
                        ),
                      ),
                      // Overlay icons for video or multiple photos
                      if (isReel)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                            shadows: [BoxShadow(color: Colors.black54, blurRadius: 4)],
                          ),
                        )
                      else if (isMulti)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.collections,
                            color: Colors.white,
                            size: 16,
                            shadows: [BoxShadow(color: Colors.black54, blurRadius: 4)],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
