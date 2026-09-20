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
  CatUser _user = AuthService().lastUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final loaded = await AuthService().loadLastUser();
    if (mounted && loaded != null) {
      setState(() {
        _user = loaded;
      });
    }
  }

  void _handleOneTapLogin() async {
    final identifier = await AuthService().getLastIdentifier() ?? _user.username;
    final password = await AuthService().getLastPassword();

    if (password != null && password.isNotEmpty) {
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
          _showPasswordPrompt(context, identifier);
        }
      }
    } else {
      if (mounted) {
        _showPasswordPrompt(context, identifier);
      }
    }
  }

  void _showPasswordPrompt(BuildContext context, String identifier) {
    final passwordController = TextEditingController();
    bool obscure = true;
    String? errorMessage;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCanvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.surfaceSecondary,
                  backgroundImage: _user.avatarUrl.isNotEmpty
                      ? NetworkImage(_user.avatarUrl)
                      : null,
                  child: _user.avatarUrl.isEmpty
                      ? const Icon(Icons.pets, size: 36, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Log in as @${_user.username}',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter password to continue',
                  style: AppTypography.captionTimestamp.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                if (errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      errorMessage!,
                      style: AppTypography.captionTimestamp.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    key: const ValueKey('input_modal_password'),
                    controller: passwordController,
                    obscureText: obscure,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTypography.bodyRegular.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Password',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Icon(
                          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setModalState(() => obscure = !obscure),
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    key: const ValueKey('btn_modal_login'),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final pass = passwordController.text.trim();
                            if (pass.isEmpty) {
                              setModalState(() {
                                errorMessage = 'Please enter your password';
                              });
                              return;
                            }
                            setModalState(() {
                              isSubmitting = true;
                              errorMessage = null;
                            });
                            try {
                              await AuthService().login(identifier: identifier, password: pass);
                              if (bottomSheetContext.mounted) {
                                Navigator.of(bottomSheetContext).pop();
                              }
                              widget.onLoginSuccess();
                            } catch (e) {
                              setModalState(() {
                                isSubmitting = false;
                                errorMessage = e.toString().replaceAll('Exception: ', '');
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Log In',
                            style: AppTypography.bodyBold.copyWith(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(bottomSheetContext).pop();
                    _handleSwitchAccount();
                  },
                  child: Text(
                    'Log into another account',
                    style: AppTypography.bodySm.copyWith(color: AppColors.linkBlue),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
