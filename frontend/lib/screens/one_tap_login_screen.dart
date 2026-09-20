import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OneTapLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onSwitchAccount;

  const OneTapLoginScreen({
    super.key,
    required this.onLoginSuccess,
    this.onSwitchAccount,
  });

  @override
  State<OneTapLoginScreen> createState() => _OneTapLoginScreenState();
}

class _OneTapLoginScreenState extends State<OneTapLoginScreen> {
  bool _isLoading = false;
  late CatUser _user;

  @override
  void initState() {
    super.initState();
    _user = AuthService().lastUser;
    _loadLastUser();
  }

  Future<void> _loadLastUser() async {
    final loaded = await AuthService().loadLastUser();
    if (mounted && loaded != null) {
      setState(() {
        _user = loaded;
      });
    }
  }

  void _handleOneTapLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        await AuthService().login(identifier: _user.username, password: 'password123');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          widget.onLoginSuccess();
        }
        return;
      }

      final identifier = await AuthService().getLastIdentifier() ?? _user.username;
      final password = await AuthService().getLastPassword();

      if (password != null && password.isNotEmpty) {
        await AuthService().login(identifier: identifier, password: password);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          widget.onLoginSuccess();
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _handleSwitchAccount();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _handleSwitchAccount();
      }
    }
  }

  void _handleSwitchAccount() {
    if (widget.onSwitchAccount != null) {
      widget.onSwitchAccount!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onLoginSuccess: widget.onLoginSuccess,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _handleSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          onRegisterSuccess: widget.onLoginSuccess,
          onBackToLogin: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content Area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Logo Header & Icon
                      Image.asset(
                        'assets/images/InstaCat-Logo.png',
                        width: 78,
                        height: 78,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Insta',
                            style: AppTypography.brandTitle.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 38,
                            ),
                          ),
                          Text(
                            'Cat',
                            style: AppTypography.brandTitle.copyWith(
                              color: AppColors.primary,
                              fontSize: 38,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'THE PURR-FECT PET COMMUNITY',
                        style: AppTypography.captionTimestamp.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Saved Account Profile Card
                      // 112px Avatar with Gradient Ring
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.storyGradient45,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x20F97316),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceCanvas,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: _user.avatarUrl.isNotEmpty
                                    ? Image.network(
                                        _user.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.surfaceTertiary,
                                          child: const Icon(Icons.pets, color: AppColors.primary, size: 48),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.surfaceTertiary,
                                        child: const Icon(Icons.pets, color: AppColors.primary, size: 48),
                                      ),
                              ),
                            ),
                          ),
                          // Verified Paw Badge
                          if (_user.isVerified)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.pets,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Username
                      Text(
                        _user.username,
                        style: AppTypography.headlineMd.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Category Pill
                      if (_user.category.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            _user.category,
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),

                      // One-Tap Primary Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleOneTapLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: AppColors.primary.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : Text(
                                  'Log In',
                                  style: AppTypography.bodyBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Switch Accounts Secondary Button
                      TextButton(
                        onPressed: _handleSwitchAccount,
                        child: Text(
                          'Switch accounts',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            const Divider(height: 0.8, color: AppColors.borderSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: AppTypography.bodySm),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _handleSignUp,
                    child: Text(
                      'Sign up.',
                      style: AppTypography.bodySmBold.copyWith(color: AppColors.primary),
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
}
