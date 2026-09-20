import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class InstaCatBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final CatUser currentUser;

  const InstaCatBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCanvas,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 0: Home
              _buildNavItem(
                index: 0,
                icon: currentIndex == 0 ? Icons.home : Icons.home_outlined,
                isSelected: currentIndex == 0,
              ),

              // 1: Explore / Search
              _buildNavItem(
                index: 1,
                icon: currentIndex == 1 ? Icons.search : Icons.search_rounded,
                isSelected: currentIndex == 1,
              ),

              // 2: Create Post
              _buildNavItem(
                index: 2,
                icon: currentIndex == 2 ? Icons.add_box : Icons.add_box_outlined,
                isSelected: currentIndex == 2,
              ),

              // 3: Activity / Notifications
              _buildNavItem(
                index: 3,
                icon: currentIndex == 3 ? Icons.favorite : Icons.favorite_border,
                isSelected: currentIndex == 3,
              ),

              // 4: Profile Avatar
              GestureDetector(
                key: const ValueKey('nav_profile'),
                onTap: () => onTabSelected(4),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentIndex == 4 ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderMuted,
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        currentUser.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          color: AppColors.surfaceSecondary,
                          child: const Icon(Icons.person, size: 16, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
