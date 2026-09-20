import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'screens/one_tap_login_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _checkAuth();
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

    return MaterialApp(
      title: 'InstaCat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoggedIn
          ? MainShell(
              onLogout: () async {
                await AuthService().logout();
                if (mounted) {
                  setState(() {
                    _isLoggedIn = false;
                  });
                }
              },
            )
          : OneTapLoginScreen(
              onLoginSuccess: () {
                setState(() {
                  _isLoggedIn = true;
                });
              },
            ),
    );
  }
}
