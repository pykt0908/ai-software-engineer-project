import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EditProfileScreen extends StatefulWidget {
  final CatUser user;
  final Function(CatUser)? onSave;
  final VoidCallback? onLogout;

  const EditProfileScreen({
    super.key,
    required this.user,
    this.onSave,
    this.onLogout,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _categoryController;
  late TextEditingController _websiteController;
  late TextEditingController _bioController;
  late bool _isPublic;
  File? _pickedAvatarFile;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _usernameController = TextEditingController(text: widget.user.username);
    _categoryController = TextEditingController(text: widget.user.category);
    _websiteController = TextEditingController(text: widget.user.website);
    _bioController = TextEditingController(text: widget.user.bio);
    _isPublic = widget.user.isPublic;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _categoryController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        setState(() {
          _pickedAvatarFile = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      int? avatarId;
      if (_pickedAvatarFile != null) {
        avatarId = await ProfileService().uploadAvatar(_pickedAvatarFile!);
      }

      final updated = await ProfileService().updateMe(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        isPublic: _isPublic,
        avatarId: avatarId,
      );

      AuthService().updateCurrentUser(updated);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        widget.onSave?.call(updated);
        Navigator.of(context).pop(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
          'Are you sure you want to log out of @${widget.user.username}?',
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
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (mounted) {
                if (widget.onLogout != null) {
                  widget.onLogout!();
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTypography.bodyRegular),
        ),
        leadingWidth: 70,
        title: Text('Edit Profile', style: AppTypography.headlineMd),
        centerTitle: true,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      'Done',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.8),
          child: Divider(height: 0.8, color: AppColors.borderSubtle),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Profile Photo with Camera Badge
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
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
                            child: _pickedAvatarFile != null
                                ? Image.file(_pickedAvatarFile!, fit: BoxFit.cover)
                                : Image.network(
                                    widget.user.avatarUrl,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceCanvas, width: 2),
                        ),
                        child: const Icon(
                          Icons.photo_camera,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _pickAvatar,
                  child: Text(
                    'Change Profile Photo',
                    style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 0.8, color: AppColors.borderSubtle),

          // Form fields
          _buildFormField(label: 'Name', controller: _nameController, hint: 'Pet full name'),
          _buildFormField(
            label: 'Username',
            controller: _usernameController,
            hint: 'username',
            prefixText: '@',
          ),
          _buildFormField(
            label: 'Category',
            controller: _categoryController,
            hint: 'e.g. Ragdoll • Cat Creator',
            trailingIcon: Icons.chevron_right,
          ),
          _buildFormField(
            label: 'Website',
            controller: _websiteController,
            hint: 'https://yourcat.link',
            prefixIcon: Icons.link,
            textColor: AppColors.primary,
          ),

          // Bio field with Char count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bio', style: AppTypography.bodyBold),
                    Text(
                      '${_bioController.text.length}/150',
                      style: AppTypography.captionTimestamp,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  child: TextField(
                    controller: _bioController,
                    maxLines: 3,
                    maxLength: 150,
                    style: AppTypography.bodyRegular,
                    decoration: InputDecoration(
                      hintText: 'Tell fellow cat lovers about your pet...',
                      hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 0.8, color: AppColors.borderSubtle),

          // Privacy Settings Toggle
          SwitchListTile(
            activeThumbColor: AppColors.primary,
            title: Text('Public Profile', style: AppTypography.bodyBold),
            subtitle: Text(
              _isPublic
                  ? 'Anyone can see your cat photos and profile'
                  : 'Only followers can see your cat photos',
              style: AppTypography.captionTimestamp,
            ),
            value: _isPublic,
            onChanged: (val) {
              setState(() {
                _isPublic = val;
              });
            },
          ),
          const Divider(height: 0.8, color: AppColors.borderSubtle),

          // Switch to Professional / Creator Account
          ListTile(
            title: Text(
              'Switch to Cat Creator Account',
              style: AppTypography.bodyBold.copyWith(color: AppColors.primary),
            ),
            onTap: () {},
          ),
          const Divider(height: 0.8, color: AppColors.borderSubtle),

          ListTile(
            title: Text('Personal Information Settings', style: AppTypography.bodyRegular),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout, size: 18, color: AppColors.interactiveLike),
                label: Text(
                  'Log Out (@${widget.user.username})',
                  style: AppTypography.bodyBold.copyWith(color: AppColors.interactiveLike),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.interactiveLike.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? prefixText,
    IconData? prefixIcon,
    IconData? trailingIcon,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 0.8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTypography.bodyBold),
          ),
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          if (prefixText != null)
            Text(prefixText, style: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary)),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyRegular.copyWith(color: textColor ?? AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.textPlaceholder),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
