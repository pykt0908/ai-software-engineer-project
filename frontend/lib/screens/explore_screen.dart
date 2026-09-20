import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

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
    _searchController.dispose();
    super.dispose();
  }

  void _showMediaDetail(BuildContext context, String imageUrl, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pets, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Cat Explore #${index + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
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

  @override
  Widget build(BuildContext context) {
    final images = MockData.exploreImages;

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
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                    });
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
        bottom: PreferredSize(
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
      body: GridView.builder(
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
            onTap: () => _showMediaDetail(context, imageUrl, index),
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
