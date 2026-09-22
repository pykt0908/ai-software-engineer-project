import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/ai_caption_widgets.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/post_composer_extras.dart';
import 'ai_photo_studio_screen.dart';
import 'gallery_picker_screen.dart';

class CreatePostScreen extends StatefulWidget {
  final Function(Post)? onPostCreated;
  final List<File>? initialFiles;

  const CreatePostScreen({
    super.key,
    this.onPostCreated,
    this.initialFiles,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final List<File> _selectedFiles = [];
  int _currentImageIndex = 0;
  bool _isSharing = false;
  int _selectedFilterIndex = 0;
  String _selectedLocation = '';
  List<String> _taggedUsernames = [];
  bool _openingGallery = false;
  bool _isGeneratingCaption = false;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'colorFilter': null},
    {
      'name': 'Warm Glow',
      'colorFilter': ColorFilter.mode(
        Colors.orange.withValues(alpha: 0.15),
        BlendMode.colorBurn,
      ),
    },
    {
      'name': 'Golden Hour',
      'colorFilter': ColorFilter.mode(
        Colors.amber.withValues(alpha: 0.2),
        BlendMode.overlay,
      ),
    },
    {
      'name': 'Vintage Cat',
      'colorFilter': ColorFilter.mode(
        Colors.brown.withValues(alpha: 0.2),
        BlendMode.multiply,
      ),
    },
    {
      'name': 'Soft Purr',
      'colorFilter': ColorFilter.mode(
        Colors.pink.withValues(alpha: 0.1),
        BlendMode.softLight,
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFiles;
    if (initial != null && initial.isNotEmpty) {
      _selectedFiles.addAll(initial.take(10));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openGalleryPicker(exitIfCancelled: true);
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _openGalleryPicker({bool exitIfCancelled = false}) async {
    if (_openingGallery) return;
    _openingGallery = true;
    try {
      final files = await Navigator.of(context).push<List<File>>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const GalleryPickerScreen(maxImages: 10),
        ),
      );
      if (!mounted) return;
      if (files == null || files.isEmpty) {
        if (exitIfCancelled && _selectedFiles.isEmpty) {
          Navigator.of(context).maybePop();
        }
        return;
      }
      setState(() {
        _selectedFiles
          ..clear()
          ..addAll(files.take(10));
        _currentImageIndex = 0;
      });
    } finally {
      _openingGallery = false;
    }
  }

  Future<void> _addMorePhotos() async {
    final remaining = 10 - _selectedFiles.length;
    if (remaining <= 0) {
      AppSnackBar.info(context, 'Maximum 10 photos allowed per post');
      return;
    }
    final files = await Navigator.of(context).push<List<File>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GalleryPickerScreen(maxImages: remaining),
      ),
    );
    if (!mounted || files == null || files.isEmpty) return;
    setState(() {
      for (final f in files) {
        if (_selectedFiles.length < 10) _selectedFiles.add(f);
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      if (_selectedFiles.isEmpty) {
        _openGalleryPicker(exitIfCancelled: true);
        return;
      }
      if (_currentImageIndex >= _selectedFiles.length) {
        _currentImageIndex = _selectedFiles.length - 1;
      }
    });
  }

  void _toggleHashtag(String tag) {
    setState(() {
      _captionController.text =
          appendHashtagToCaption(_captionController.text, tag);
      _captionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _captionController.text.length),
      );
    });
  }

  Future<void> _pickLocation() async {
    final result = await showLocationPickerSheet(
      context,
      current: _selectedLocation,
    );
    if (result != null && mounted) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _pickTaggedFriends() async {
    final result = await showTagFriendsSheet(
      context,
      current: _taggedUsernames,
    );
    if (result != null && mounted) {
      setState(() => _taggedUsernames = result);
    }
  }

  Future<void> _openAiCaptionSheet() async {
    if (_selectedFiles.isEmpty || _isGeneratingCaption || _isSharing) return;

    final index = _currentImageIndex.clamp(0, _selectedFiles.length - 1);
    final imageFile = _selectedFiles[index];

    setState(() => _isGeneratingCaption = true);
    try {
      final selected = await showAiCaptionSuggestionSheet(
        context,
        imageFile: imageFile,
      );
      if (!mounted || selected == null || selected.isEmpty) return;
      setState(() {
        _captionController.text = selected;
        _captionController.selection = TextSelection.fromPosition(
          TextPosition(offset: _captionController.text.length),
        );
      });
    } finally {
      if (mounted) setState(() => _isGeneratingCaption = false);
    }
  }

  Future<void> _openAiPhotoStudio() async {
    if (_selectedFiles.isEmpty || _isSharing) return;

    final index = _currentImageIndex.clamp(0, _selectedFiles.length - 1);
    final currentFile = _selectedFiles[index];

    final editedFile = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => AiPhotoStudioScreen(originalFile: currentFile),
      ),
    );

    if (editedFile != null && mounted) {
      setState(() {
        _selectedFiles[index] = editedFile;
      });
      AppSnackBar.success(context, 'อัปเดตรูปภาพด้วยผลลัพธ์จาก AI แล้ว 🐾');
    }
  }

  Future<void> _handleShare() async {
    if (_selectedFiles.isEmpty) {
      AppSnackBar.error(context, 'Please select at least 1 cat photo to share');
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final imageIds = await PostService().uploadImages(_selectedFiles);

      final caption = _captionController.text.trim();
      final newPost = await PostService().createPost(
        caption: caption.isNotEmpty
            ? caption
            : 'Enjoying my day with lots of purrs! 🐾',
        imageIds: imageIds,
        location: _selectedLocation,
        taggedUsernames: _taggedUsernames,
      );

      if (mounted) {
        setState(() {
          _isSharing = false;
        });

        widget.onPostCreated?.call(newPost);
        AppSnackBar.success(context, 'Your cat post has been published!');
        Navigator.of(context).maybePop(newPost);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
        AppSnackBar.error(context, 'Failed to publish post: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          leading: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(
              'Cancel',
              style: AppTypography.bodyRegular
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
          title: Text('New Post', style: AppTypography.headlineMd),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'You must be logged in to create a post.',
              style: AppTypography.bodyRegular
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_selectedFiles.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final taggedSubtitle = _taggedUsernames.isEmpty
        ? 'Tag people in your post'
        : _taggedUsernames.map((u) => '@$u').join(', ');
    final locationSubtitle =
        _selectedLocation.isEmpty ? 'Add a location' : _selectedLocation;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _isSharing ? null : () => Navigator.of(context).maybePop(),
          child: Text(
            'Cancel',
            style: AppTypography.bodyRegular
                .copyWith(color: AppColors.textPrimary),
          ),
        ),
        leadingWidth: 70,
        title: Text('New Post', style: AppTypography.headlineMd),
        centerTitle: true,
        actions: [
          _isSharing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _handleShare,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      'Share',
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
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: _filters[_selectedFilterIndex]['colorFilter'] ??
                      const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.dst,
                      ),
                  child: PageView.builder(
                    itemCount: _selectedFiles.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImageIndex = i),
                    itemBuilder: (ctx, i) {
                      final file = _selectedFiles[i];
                      if (kIsWeb) {
                        return Image.network(
                          file.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.black12,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white38,
                            ),
                          ),
                        );
                      }
                      return Image.file(
                        file,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1} / ${_selectedFiles.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => _removeImage(_currentImageIndex),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openGalleryPicker(),
                        icon: const Icon(Icons.photo_library_outlined, size: 14),
                        label: const Text('Change'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        onPressed: _openAiPhotoStudio,
                        icon: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                        label: const Text(
                          '✨ AI แต่งภาพ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.92),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedFiles.length < 10)
                        ElevatedButton.icon(
                          onPressed: _addMorePhotos,
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 48,
            color: AppColors.surfaceSecondary,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceCanvas,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _filters[index]['name'] as String,
                        style: AppTypography.labelSm.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 0.8, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(currentUser.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Write a caption for your cat post...',
                      hintStyle: AppTypography.bodyRegular
                          .copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: AppTypography.bodyRegular,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: AiCaptionGenerateButton(
              enabled: _selectedFiles.isNotEmpty &&
                  !_isSharing &&
                  !_isGeneratingCaption,
              onPressed: _openAiCaptionSheet,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POPULAR CAT HASHTAGS',
                  style: AppTypography.captionTimestamp.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kSuggestedHashtags.map((tag) {
                    final active = _captionController.text
                        .split(RegExp(r'\s+'))
                        .any((p) => p.toLowerCase() == tag.toLowerCase());
                    return GestureDetector(
                      onTap: () => _toggleHashtag(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.surfaceTertiary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.bodySm.copyWith(
                            color: active ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 0.8, color: AppColors.borderSubtle),
          ListTile(
            leading: const Icon(Icons.pets, color: AppColors.primary, size: 20),
            title: Text('Tag Cats & Friends', style: AppTypography.bodyBold),
            subtitle: Text(
              taggedSubtitle,
              style: AppTypography.bodySm.copyWith(
                color: _taggedUsernames.isEmpty
                    ? AppColors.textSecondary
                    : AppColors.primary,
              ),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _pickTaggedFriends,
          ),
          const Divider(height: 0.8, indent: 50, color: AppColors.borderSubtle),
          ListTile(
            leading: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 20,
            ),
            title: Text('Add Location', style: AppTypography.bodyBold),
            subtitle: Text(locationSubtitle, style: AppTypography.bodySm),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _pickLocation,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
