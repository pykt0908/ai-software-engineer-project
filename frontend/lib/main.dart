import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'screens/switch_account_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InstaCatApp());
}

class InstaCatApp extends StatefulWidget {
  const InstaCatApp({super.key});

  @override
  State<InstaCatApp> createState() => _InstaCatAppState();
}

class _InstaCatAppState extends State<InstaCatApp> {
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  int _shellGeneration = 0;

  @override
  void initState() {
    super.initState();
    AuthService().currentUserNotifier.addListener(_onCurrentUserChanged);
    _checkAuth();
  }

  @override
  void dispose() {
    AuthService().currentUserNotifier.removeListener(_onCurrentUserChanged);
    super.dispose();
  }

  void _onCurrentUserChanged() {
    final user = AuthService().currentUser;
    if (user == null && _isLoggedIn && mounted) {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService().init();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isInitialized = true;
      });
    }
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
      _shellGeneration++;
    });
  }

  void _onLogout() async {
    await AuthService().logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  void _onAccountSwitched() {
    // Session already replaced by AuthService.login; rebuild MainShell for new user.
    setState(() {
      _isLoggedIn = true;
      _shellGeneration++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'InstaCat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF97316),
            ),
          ),
        ),
      );
    }

    final userId = AuthService().currentUser?.id ?? 'guest';

    return MaterialApp(
      title: 'InstaCat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoggedIn
          ? MainShell(
              key: ValueKey('shell_${userId}_$_shellGeneration'),
              onLogout: _onLogout,
              onAccountSwitched: _onAccountSwitched,
            )
          : SwitchAccountScreen(
              onLoginSuccess: _onLoginSuccess,
            ),
    );
  }
}
