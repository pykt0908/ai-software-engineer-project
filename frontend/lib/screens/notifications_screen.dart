import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'post_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final bool showBackButton;
  final Function(CatUser)? onUserSelected;

  const NotificationScreen({
    super.key,
    this.showBackButton = true,
    this.onUserSelected,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationItem> _notifications;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Likes', 'Comments', 'Follows', 'Treats'];

  @override
  void initState() {
    super.initState();
    _notifications = List.from(MockData.notifications);
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    if (_selectedFilter == 'Likes') {
      return _notifications.where((n) => n.type == NotificationType.like).toList();
    }
    if (_selectedFilter == 'Comments') {
      return _notifications.where((n) => n.type == NotificationType.comment || n.type == NotificationType.mention).toList();
    }
    if (_selectedFilter == 'Follows') {
      return _notifications.where((n) => n.type == NotificationType.follow).toList();
    }
    if (_selectedFilter == 'Treats') {
      return _notifications.where((n) => n.type == NotificationType.treat).toList();
    }
    return _notifications;
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      MockData.notifications = List.from(_notifications);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('All notifications marked as read'),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFollow(NotificationItem item) {
    final index = _notifications.indexWhere((n) => n.id == item.id);
    if (index != -1) {
      setState(() {
        final updated = _notifications[index].copyWith(
          isFollowing: !_notifications[index].isFollowing,
        );
        _notifications[index] = updated;
      });
    }
  }

  void _removeNotification(NotificationItem item) {
    final removedIndex = _notifications.indexWhere((n) => n.id == item.id);
    final removedItem = item;

    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification removed'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _notifications.insert(removedIndex, removedItem);
            });
          },
        ),
      ),
    );
  }

  void _onNotificationTap(NotificationItem item) {
    // Mark this specific item as read
    final index = _notifications.indexWhere((n) => n.id == item.id);
    if (index != -1 && !_notifications[index].isRead) {
      setState(() {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      });
    }

    if (item.postImageUrl != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(
            posts: MockData.feedPosts,
            initialIndex: 0,
            title: 'Post',
          ),
        ),
      );
    } else if (item.type == NotificationType.follow && widget.onUserSelected != null) {
      widget.onUserSelected!(item.user);
    }
  }

  Widget _buildTypeBadgeIcon(NotificationType type) {
    IconData icon;
    Color bgColor;

    switch (type) {
      case NotificationType.like:
        icon = Icons.favorite;
        bgColor = AppColors.interactiveLike;
        break;
      case NotificationType.comment:
        icon = Icons.chat_bubble;
        bgColor = const Color(0xFF3B82F6);
        break;
      case NotificationType.follow:
        icon = Icons.person_add;
        bgColor = AppColors.primary;
        break;
      case NotificationType.treat:
        icon = Icons.pets;
        bgColor = const Color(0xFFEAB308);
        break;
      case NotificationType.mention:
        icon = Icons.alternate_email;
        bgColor = const Color(0xFF8B5CF6);
        break;
    }

    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Icon(icon, size: 9, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final unreadItems = filtered.where((n) => !n.isRead).toList();
    final readItems = filtered.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                splashRadius: 20,
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        titleSpacing: widget.showBackButton ? 0 : 16,
        title: Row(
          children: [
            Text('Notifications', style: AppTypography.headlineMd),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount new',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primary),
              label: Text(
                'Mark read',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
          // Filter Chips Row
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCanvas,
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 0.6)),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceSecondary,
                  labelStyle: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                    width: 0.8,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },
            ),
          ),

          // Main Notifications List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                      setState(() {
                        _notifications = List.from(MockData.notifications);
                      });
                    },
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        if (unreadItems.isNotEmpty) ...[
                          _buildSectionHeader('New'),
                          ...unreadItems.map((item) => _buildNotificationTile(item)),
                        ],
                        if (readItems.isNotEmpty) ...[
                          _buildSectionHeader(unreadItems.isEmpty ? 'All Activity' : 'Earlier'),
                          ...readItems.map((item) => _buildNotificationTile(item)),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: AppTypography.bodyBold.copyWith(
          fontSize: 13,
          color: AppColors.textPrimary,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.interactiveLike,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => _removeNotification(item),
      child: InkWell(
        onTap: () => _onNotificationTap(item),
        child: Container(
          color: item.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Type Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => widget.onUserSelected?.call(item.user),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.surfaceTertiary,
                      backgroundImage: NetworkImage(item.user.avatarUrl),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: _buildTypeBadgeIcon(item.type),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Notification Text Content
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${item.user.username} ',
                        style: AppTypography.bodyBold.copyWith(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: item.message,
                        style: AppTypography.bodyRegular.copyWith(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '  ${item.timeAgo}',
                        style: AppTypography.captionTimestamp.copyWith(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Trailing Action: Follow Button or Post Thumbnail
              if (item.type == NotificationType.follow) ...[
                ElevatedButton(
                  onPressed: () => _toggleFollow(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isFollowing ? AppColors.surfaceSecondary : AppColors.primary,
                    foregroundColor: item.isFollowing ? AppColors.textPrimary : Colors.white,
                    elevation: 0,
                    side: item.isFollowing ? const BorderSide(color: AppColors.borderSubtle) : BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    item.isFollowing ? 'Following' : 'Follow Back',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: item.isFollowing ? AppColors.textPrimary : Colors.white,
                    ),
                  ),
                ),
              ] else if (item.postImageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.postImageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 44,
                      height: 44,
                      color: AppColors.surfaceSecondary,
                      child: const Icon(Icons.pets, size: 20, color: AppColors.primary),
                    ),
                  ),
                ),
              ],

              // Unread Dot Indicator
              if (!item.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: AppTypography.headlineMd,
            ),
            const SizedBox(height: 6),
            Text(
              _selectedFilter == 'All'
                  ? "You're all caught up! Purr-fect day ahead 🐾"
                  : 'No $_selectedFilter notifications found.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
