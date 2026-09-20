import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

import '../services/auth_service.dart';
import '../widgets/app_snackbar.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onBack;

  const LoginScreen({super.key, required this.onLoginSuccess, this.onBack});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final identifier = _usernameController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      AppSnackBar.error(
        context,
        'Please enter both username/email and password',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().login(identifier: identifier, password: password);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppSnackBar.error(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  void _openRegisterScreen() {
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
    final canGoBack = Navigator.canPop(context) || widget.onBack != null;

    return Scaffold(
      appBar: canGoBack
          ? AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // InstaCat Brand App Logo
                Image.asset(
                  'assets/images/InstaCat-Logo.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),

                // Brand Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Insta',
                      style: AppTypography.brandTitle.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 34,
                      ),
                    ),
                    Text(
                      'Cat',
                      style: AppTypography.brandTitle.copyWith(
                        color: AppColors.primary,
                        fontSize: 34,
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
                const SizedBox(height: 36),

                // Username / Email Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _usernameController,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.bodyRegular,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Phone number, username, or email',
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: AppColors.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Password Input with Visibility Toggle
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.bodyRegular,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Password',
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: AppColors.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 20,
                      ),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        splashRadius: 20,
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      AppSnackBar.info(
                        context,
                        'Password reset instructions sent',
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: AppTypography.bodySmBold.copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Primary Log In Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.pets, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Log In',
                                style: AppTypography.bodyBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Divider with "OR"
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.borderSubtle),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR',
                        style: AppTypography.captionTimestamp.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPlaceholder,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.borderSubtle),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Social Login Buttons
                TextButton.icon(
                  onPressed: () => widget.onLoginSuccess(),
                  icon: const Icon(
                    Icons.facebook,
                    color: AppColors.linkBlue,
                    size: 22,
                  ),
                  label: Text(
                    'Log in with Facebook',
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.linkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Sign up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: AppTypography.bodySm),
                    TextButton(
                      onPressed: _openRegisterScreen,
                      child: Text(
                        ' Sign up.',
                        style: AppTypography.bodySmBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
