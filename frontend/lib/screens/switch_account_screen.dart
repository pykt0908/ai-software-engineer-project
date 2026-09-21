import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_snackbar.dart';
import 'register_screen.dart';

class SwitchAccountScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onBack;

  const SwitchAccountScreen({
    super.key,
    required this.onLoginSuccess,
    this.onBack,
  });

  @override
  State<SwitchAccountScreen> createState() => _SwitchAccountScreenState();
}

class _SwitchAccountScreenState extends State<SwitchAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _userLoaded = false;
  CatUser? _lastUser;

  @override
  void initState() {
    super.initState();
    _loadLastUser();
  }

  Future<void> _loadLastUser() async {
    final loaded = await AuthService().loadLastUser();
    final identifier = await AuthService().getLastIdentifier();
    if (!mounted) return;
    setState(() {
      _lastUser = loaded;
      _userLoaded = true;
      if (identifier != null && identifier.isNotEmpty) {
        _usernameController.text = identifier;
      } else if (loaded != null && loaded.username.isNotEmpty) {
        _usernameController.text = loaded.username;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _prefillFromLastUser() {
    final user = _lastUser;
    if (user == null) return;
    setState(() {
      _usernameController.text = user.username;
      _passwordController.clear();
    });
  }

  Future<void> _handleLogin() async {
    final identifier = _usernameController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      AppSnackBar.error(
        context,
        'Please enter both username/email and password',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().login(identifier: identifier, password: password);
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void _openRegisterScreen() async {
    final registeredUsername = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          onBackToLogin: () => Navigator.of(context).pop(),
        ),
      ),
    );

    if (!mounted) return;
    await _loadLastUser();
    if (registeredUsername != null && registeredUsername.isNotEmpty) {
      setState(() {
        _usernameController.text = registeredUsername;
        _passwordController.clear();
      });
      AppSnackBar.success(
        context,
        'Account created successfully! Please sign in.',
      );
    }
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildLastAccountRow(CatUser user) {
    return Material(
      color: AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _prefillFromLastUser,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceTertiary,
                backgroundImage:
                    user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                child: user.avatarUrl.isEmpty
                    ? const Icon(Icons.pets, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username, style: AppTypography.bodyBold),
                    Text(
                      'Tap to use this account',
                      style: AppTypography.captionTimestamp.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textAlignVertical: TextAlignVertical.center,
        style: AppTypography.bodyRegular,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: AppTypography.bodySm.copyWith(
            color: AppColors.textPlaceholder,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context) || widget.onBack != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBrandHeader(),
                      const SizedBox(height: 28),
                      Text(
                        'Switch accounts',
                        style: AppTypography.headlineMd.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log in with username and password to continue.',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!_userLoaded)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      else ...[
                        if (_lastUser != null) ...[
                          _buildLastAccountRow(_lastUser!),
                          const SizedBox(height: 16),
                        ],
                        _buildInput(
                          controller: _usernameController,
                          hint: 'Phone number, username, or email',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          suffix: IconButton(
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
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                : Text(
                                    'Log In',
                                    style: AppTypography.bodyBold.copyWith(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 0.8, color: AppColors.borderSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: AppTypography.bodySm),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _openRegisterScreen,
                    child: Text(
                      'Sign up.',
                      style: AppTypography.bodySmBold.copyWith(
                        color: AppColors.primary,
                      ),
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
