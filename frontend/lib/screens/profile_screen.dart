import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'edit_profile_screen.dart';
import 'one_tap_login_screen.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final CatUser? user;
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.user, this.onLogout});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  CatUser _user = MockData.currentUser;
  late TabController _tabController;
  List<Post> _userPosts = [];
  final List<StoryHighlight> _highlights = MockData.profileHighlights;
  bool _isLoadingPosts = false;

  bool get _isOwnProfile {
    final current = AuthService().currentUser;
    if (widget.user == null) return true;
    if (current == null) return false;
    return widget.user!.id == current.id || widget.user!.username == current.username;
  }

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _user = widget.user!;
    } else if (AuthService().currentUser != null) {
      _user = AuthService().currentUser!;
    }
    if (_user.username == 'mochi_the_ragdoll') {
      _userPosts = MockData.currentUserPosts;
    } else {
      _userPosts = [];
    }
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != null &&
        (widget.user!.id != oldWidget.user?.id ||
            widget.user!.username != oldWidget.user?.username ||
            widget.user!.postsCount != oldWidget.user?.postsCount)) {
      _user = widget.user!;
      _loadProfile();
    }
  }

  Future<void> refresh() => _loadProfile();

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoadingPosts = true;
      });
    }

    String usernameToFetch = _user.username;
    try {
      final user = _isOwnProfile
          ? await ProfileService().getMe()
          : await ProfileService().getProfile(_user.username);
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
      usernameToFetch = user.username;
    } catch (_) {}

    try {
      if (usernameToFetch.isNotEmpty) {
        final posts = await PostService().getUserPosts(usernameToFetch);
        if (mounted) {
          setState(() {
            _userPosts = posts;
            _isLoadingPosts = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPosts = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_userPosts.isEmpty && _user.username == 'mochi_the_ragdoll') {
            _userPosts = MockData.currentUserPosts;
          }
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    try {
      final res = await ProfileService().toggleFollow(
        targetDocumentId: _user.id,
        currentFollowing: _user.isFollowing,
      );
      if (mounted) {
        setState(() {
          _user = _user.copyWith(
            isFollowing: res['following'] as bool,
            followersCount: res['followersCount'].toString(),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Follow action failed: $e')),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final messenger = ScaffoldMessenger.of(context);
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isChanging = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Change Password', style: AppTypography.headlineMd),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorText != null) ...[
                  Text(errorText!, style: AppTypography.captionSm.copyWith(color: AppColors.error)),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: currentPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                ),
                TextField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password (min 6 chars)'),
                ),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isChanging
                  ? null
                  : () async {
                      if (newPassCtrl.text != confirmPassCtrl.text) {
                        setDialogState(() => errorText = 'New passwords do not match');
                        return;
                      }
                      if (newPassCtrl.text.length < 6) {
                        setDialogState(() => errorText = 'Password must be at least 6 characters');
                        return;
                      }
                      setDialogState(() {
                        isChanging = true;
                        errorText = null;
                      });
                      try {
                        await AuthService().changePassword(
                          currentPassword: currentPassCtrl.text,
                          password: newPassCtrl.text,
                          passwordConfirmation: confirmPassCtrl.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Password updated successfully!')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isChanging = false;
                          errorText = e.toString().replaceAll('Exception: ', '');
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: isChanging
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openEditProfile() async {
    final updated = await Navigator.of(context).push<CatUser>(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          user: _user,
          onLogout: widget.onLogout,
          onSave: (newUser) {
            setState(() {
              _user = newUser;
            });
          },
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _user = updated;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.interactiveLike, size: 22),
            const SizedBox(width: 8),
            Text('Log Out', style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of @${_user.username}?',
          style: AppTypography.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.bodyBold.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.interactiveLike,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _performLogout();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    await AuthService().logout();
    if (mounted) {
      if (widget.onLogout != null) {
        widget.onLogout!();
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => OneTapLoginScreen(
              onLoginSuccess: () {},
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  void _showAccountSwitcher() {
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
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(_user.avatarUrl),
                  ),
                  title: Text(_user.username, style: AppTypography.bodyBold),
                  trailing: const Icon(Icons.check_circle, color: AppColors.primary),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceTertiary,
                    child: Icon(Icons.add, color: AppColors.textPrimary),
                  ),
                  title: Text('Switch or Add Account', style: AppTypography.bodyBold),
                  subtitle: Text('Open Login or One-Tap Login', style: AppTypography.captionTimestamp),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OneTapLoginScreen(
                          onLoginSuccess: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
                if (_isOwnProfile) ...[
                  const Divider(color: AppColors.borderSubtle),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(Icons.logout, color: AppColors.interactiveLike),
                    ),
                    title: Text(
                      'Log Out',
                      style: AppTypography.bodyBold.copyWith(color: AppColors.interactiveLike),
                    ),
                    subtitle: Text('Log out of @${_user.username}', style: AppTypography.captionTimestamp),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogout();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            if (_isOwnProfile) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                title: Text('Edit Profile', style: AppTypography.bodyBold),
                subtitle: Text('Update your photo, display name, and bio', style: AppTypography.captionTimestamp),
                onTap: () {
                  Navigator.pop(context);
                  _openEditProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                title: Text('Change Password', style: AppTypography.bodyBold.copyWith(color: AppColors.primary)),
                subtitle: Text('Update your account password', style: AppTypography.captionTimestamp),
                onTap: () {
                  Navigator.pop(context);
                  _showChangePasswordDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.switch_account_outlined, color: AppColors.textPrimary),
                title: Text('Switch Account', style: AppTypography.bodyBold),
                subtitle: Text('Open Login or One-Tap Login screen', style: AppTypography.captionTimestamp),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OneTapLoginScreen(
                        onLoginSuccess: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
              ),
              const Divider(color: AppColors.borderSubtle),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.interactiveLike),
                title: Text(
                  'Log Out',
                  style: AppTypography.bodyBold.copyWith(color: AppColors.interactiveLike),
                ),
                subtitle: Text('Sign out of @${_user.username}', style: AppTypography.captionTimestamp),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout();
                },
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
        titleSpacing: 16,
        title: GestureDetector(
          onTap: _showAccountSwitcher,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                _user.username,
                style: AppTypography.headlineMd.copyWith(fontSize: 19),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textPrimary),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, size: 24, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Story or Reel')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, size: 26, color: AppColors.textPrimary),
            onPressed: _showOptionsMenu,
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.8),
          child: Divider(height: 0.8, color: AppColors.borderSubtle),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar and Stats Row
                    Row(
                      children: [
                        // Profile Avatar with Gradient Ring & Paw Badge
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.storyGradient45,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceCanvas,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    _user.avatarUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surfaceCanvas, width: 2),
                              ),
                              child: const Icon(Icons.pets, color: Colors.white, size: 12),
                            ),
                          ],
                        ),

                        // Stats Columns (Posts, Followers, Following)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(
                                'Posts',
                                (_userPosts.length > _user.postsCount
                                        ? _userPosts.length
                                        : _user.postsCount)
                                    .toString(),
                              ),
                              _buildStatColumn('Followers', _user.followersCount),
                              _buildStatColumn('Following', _user.followingCount.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Display Name & Badges
                    Row(
                      children: [
                        Text(
                          _user.displayName,
                          style: AppTypography.bodyBold.copyWith(fontSize: 15),
                        ),
                        if (_user.category.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _user.category,
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Bio text
                    Text(
                      _user.bio,
                      style: AppTypography.bodyRegular.copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 4),

                    // Website Link
                    if (_user.website.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.language, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Opening https://${_user.website}')),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.link, size: 15, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _user.website,
                              style: AppTypography.bodySmBold.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Action Buttons Row (Edit Profile / Follow, Share Profile, Discover)
                    Row(
                      children: [
                        if (_isOwnProfile)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _openEditProfile,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.surfaceCanvas,
                                side: const BorderSide(color: AppColors.borderMuted),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 7),
                              ),
                              child: Text('Edit Profile', style: AppTypography.bodyBold),
                            ),
                          )
                        else
                          Expanded(
                            child: _user.isFollowing
                                ? OutlinedButton(
                                    onPressed: _toggleFollow,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppColors.surfaceCanvas,
                                      side: const BorderSide(color: AppColors.borderMuted),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 7),
                                    ),
                                    child: Text('Following', style: AppTypography.bodyBold),
                                  )
                                : ElevatedButton(
                                    onPressed: _toggleFollow,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 7),
                                    ),
                                    child: Text('Follow', style: AppTypography.bodyBold.copyWith(color: Colors.white)),
                                  ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.share, color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text('Profile link shared!'),
                                    ],
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.surfaceCanvas,
                              side: const BorderSide(color: AppColors.borderMuted),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 7),
                            ),
                            child: Text('Share Profile', style: AppTypography.bodyBold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTertiary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderMuted),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.person_add_outlined, size: 18, color: AppColors.textPrimary),
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Story Highlights Tray
                    SizedBox(
                      height: 86,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _highlights.length,
                        itemBuilder: (context, index) {
                          final hl = _highlights[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.borderMuted),
                                    color: AppColors.surfaceCanvas,
                                  ),
                                  child: hl.isNew
                                      ? const Center(
                                          child: Icon(Icons.add, color: AppColors.textPrimary, size: 24),
                                        )
                                      : ClipOval(
                                          child: Image.network(
                                            hl.coverImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, st) => const Icon(Icons.pets, color: AppColors.primary),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hl.title,
                                  style: AppTypography.labelSm.copyWith(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar pinned
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 1.5,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on, size: 22)),
                    Tab(icon: Icon(Icons.video_library_outlined, size: 22)),
                    Tab(icon: Icon(Icons.assignment_ind_outlined, size: 22)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Grid of Posts
            RefreshIndicator(
              onRefresh: _loadProfile,
              color: AppColors.primary,
              child: _isLoadingPosts && _userPosts.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : _userPosts.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 48),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight.withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 32,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Posts Yet',
                                      style: AppTypography.headlineMd,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isOwnProfile
                                          ? 'Share your first cat moment with the community! 🐾'
                                          : 'This cat hasn\'t posted any photos yet.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyRegular.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(1.5),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1.5,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _userPosts.length,
                          itemBuilder: (context, index) {
                            final post = _userPosts[index];
                            final isMulti = post.imageUrls.length > 1;

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(
                                      posts: _userPosts,
                                      initialIndex: index,
                                      title: '${_user.username}\'s Posts',
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    post.imageUrls.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => Container(
                                      color: AppColors.surfaceSecondary,
                                      child: const Icon(Icons.pets, color: AppColors.borderMuted),
                                    ),
                                  ),
                                  if (isMulti)
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
            ),

            // Tab 2: Reels
            GridView.builder(
              padding: const EdgeInsets.all(1.5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.5,
                mainAxisSpacing: 1.5,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 0.75,
                                child: Image.network(
                                  MockData.exploreImages[index],
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
                                  child: const Row(
                                    children: [
                                      Icon(Icons.pets, color: AppColors.primary, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Reel Preview',
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                              Icon(
                                Icons.play_circle_fill,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 64,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        MockData.exploreImages[index],
                        fit: BoxFit.cover,
                      ),
                      const Positioned(
                        bottom: 6,
                        left: 6,
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow, color: Colors.white, size: 14),
                            SizedBox(width: 2),
                            Text('14.2k', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Tab 3: Tagged
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 48, color: AppColors.borderMuted),
                  const SizedBox(height: 8),
                  Text('No tagged photos yet', style: AppTypography.bodyBold),
                  Text('Photos of you by other cats will appear here', style: AppTypography.bodySm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTypography.headlineMd),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySm),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surfaceCanvas,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
