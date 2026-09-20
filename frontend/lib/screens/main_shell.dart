import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'create_post_screen.dart';
import 'explore_screen.dart';
import 'feed_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainShell({super.key, this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();

  void _onTabSelected(int index) {
    if (index == 2) {
      // Create Post modal
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => CreatePostScreen(
            onPostCreated: (newPost) {
              setState(() {
                _currentIndex = 0;
              });
              _profileKey.currentState?.refresh();
            },
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
      if (index == 4) {
        _profileKey.currentState?.refresh();
      }
    }
  }

  void _openUserProfile(CatUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          user: user,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CatUser?>(
      valueListenable: AuthService().currentUserNotifier,
      builder: (context, currentUser, child) {
        final activeUser = currentUser ?? MockData.currentUser;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              FeedScreen(
                onUserSelected: _openUserProfile,
              ),
              const ExploreScreen(),
              const SizedBox(), // Placeholder for Create Post (opens as modal)
              NotificationScreen(
                showBackButton: false,
                onUserSelected: _openUserProfile,
              ),
              ProfileScreen(
                key: _profileKey,
                user: activeUser,
                onLogout: widget.onLogout,
              ),
            ],
          ),
          bottomNavigationBar: InstaCatBottomNavBar(
            currentIndex: _currentIndex,
            onTabSelected: _onTabSelected,
            currentUser: activeUser,
          ),
        );
      },
    );
  }
}
