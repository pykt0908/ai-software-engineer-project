import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback? onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Client-side validations
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _errorMessage = 'Username must be at least 3 characters long';
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(username)) {
      setState(() {
        _errorMessage = 'Username can only contain letters, numbers, dots, and underscores';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().register(
        username: username,
        email: email,
        password: password,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onRegisterSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _goToLogin() {
    if (widget.onBackToLogin != null) {
      widget.onBackToLogin!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onLoginSuccess: widget.onRegisterSuccess,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: _goToLogin,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Header
                Image.asset(
                  'assets/images/InstaCat-Logo.png',
                  width: 68,
                  height: 68,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 8),
                Text(
                  'Sign up to share and discover adorable cat moments 🐾',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),

                // Error Message Banner
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.error_outline, size: 18, color: AppColors.error),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Username Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _usernameController,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.bodyRegular,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Username (e.g. fluffy_cat)',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Email Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.bodyRegular,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Email address (e.g. cat@example.com)',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Password Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
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
                      hintText: 'Password (min 6 characters)',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        splashRadius: 20,
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Confirm Password Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.bodyRegular,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Confirm Password',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.lock_reset, size: 20, color: AppColors.textSecondary),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        splashRadius: 20,
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.storyGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Sign Up',
                              style: AppTypography.bodyBold.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Back to Login Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: AppTypography.bodySm),
                    TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'Log in.',
                        style: AppTypography.bodySmBold.copyWith(color: AppColors.primary),
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
