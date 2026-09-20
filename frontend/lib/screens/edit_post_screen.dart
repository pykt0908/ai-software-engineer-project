import 'dart:io';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/ai_caption_service.dart';
import '../services/post_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/ai_caption_widgets.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/post_composer_extras.dart';
import 'gallery_picker_screen.dart';

class _ExistingImage {
  final int? id;
  final String url;

  const _ExistingImage({this.id, required this.url});
}

class EditPostScreen extends StatefulWidget {
  final Post post;
  final Function(Post)? onPostUpdated;

  const EditPostScreen({
    super.key,
    required this.post,
    this.onPostUpdated,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _captionController;
  late String _location;
  late List<String> _taggedUsernames;
  bool _isSaving = false;

  late List<_ExistingImage> _existingImages;
  final List<File> _newFiles = [];
  bool _loadingImages = false;
  bool _isGeneratingCaption = false;

  int get _totalImageCount => _existingImages.length + _newFiles.length;

  bool get _hasMediaIds =>
      _existingImages.any((img) => img.id != null);

  void _applyImagesFromPost(Post post) {
    final urls = post.imageUrls;
    final ids = post.imageIds;
    _existingImages = [
      for (var i = 0; i < urls.length; i++)
        _ExistingImage(
          id: i < ids.length ? ids[i] : null,
          url: urls[i],
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    _location = widget.post.location;
    _taggedUsernames = List<String>.from(widget.post.taggedUsernames);
    _applyImagesFromPost(widget.post);
    _refreshImagesIfNeeded();
  }

  Future<void> _refreshImagesIfNeeded() async {
    if (widget.post.id.isEmpty) return;

    setState(() => _loadingImages = true);
    try {
      final fresh = await PostService().getPost(widget.post.id);
      if (!mounted) return;
      setState(() {
        if (fresh.imageUrls.isNotEmpty) {
          _applyImagesFromPost(fresh);
        }
        if (fresh.location.isNotEmpty || _location.isEmpty) {
          _location = fresh.location;
        }
        if (fresh.taggedUsernames.isNotEmpty || _taggedUsernames.isEmpty) {
          _taggedUsernames = List<String>.from(fresh.taggedUsernames);
        }
        if (fresh.caption.isNotEmpty && _captionController.text == widget.post.caption) {
          _captionController.text = fresh.caption;
        }
        _loadingImages = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingImages = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = 10 - _totalImageCount;
    if (remaining <= 0) {
      AppSnackBar.info(context, 'Maximum 10 photos allowed per post');
      return;
    }

    try {
      final files = await Navigator.of(context).push<List<File>>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => GalleryPickerScreen(maxImages: remaining),
        ),
      );
      if (!mounted || files == null || files.isEmpty) return;
      setState(() {
        for (final file in files) {
          if (_totalImageCount >= 10) break;
          _newFiles.add(file);
        }
      });
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error picking images: $e');
      }
    }
  }

  Future<void> _pickCameraImage() async {
    await _pickImages();
  }

  void _removeExisting(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNew(int index) {
    setState(() {
      _newFiles.removeAt(index);
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

  Future<File?> _resolveImageForAiCaption() async {
    if (_newFiles.isNotEmpty) {
      return _newFiles.first;
    }
    if (_existingImages.isEmpty) return null;
    final url = _existingImages.first.url;
    if (url.isEmpty) return null;
    return AiCaptionService().downloadImageToTempFile(url);
  }

  Future<void> _openAiCaptionSheet() async {
    if (_isGeneratingCaption || _isSaving || _totalImageCount == 0) return;

    setState(() => _isGeneratingCaption = true);
    try {
      final imageFile = await _resolveImageForAiCaption();
      if (!mounted) return;
      if (imageFile == null) {
        AppSnackBar.error(context, 'ไม่พบรูปสำหรับสร้าง caption');
        return;
      }

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
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingCaption = false);
    }
  }

  Future<void> _pickLocation() async {
    final result = await showLocationPickerSheet(
      context,
      current: _location,
    );
    if (result != null && mounted) {
      setState(() => _location = result);
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

  Future<void> _savePost() async {
    if (_totalImageCount == 0) {
      AppSnackBar.error(context, 'A post must have at least 1 photo');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      List<int>? imageIds;
      final keptIds = _existingImages
          .map((e) => e.id)
          .whereType<int>()
          .toList();

      if (_hasMediaIds || _newFiles.isNotEmpty) {
        final uploaded = _newFiles.isEmpty
            ? <int>[]
            : await PostService().uploadImages(_newFiles);
        imageIds = [...keptIds, ...uploaded];
        if (imageIds.isEmpty) {
          throw Exception('A post must have at least 1 photo');
        }
        if (imageIds.length > 10) {
          throw Exception('A post cannot contain more than 10 images');
        }
      }

      final updatedPost = await PostService().updatePost(
        documentId: widget.post.id,
        caption: _captionController.text.trim(),
        imageIds: imageIds,
        location: _location,
        taggedUsernames: _taggedUsernames,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        widget.onPostUpdated?.call(updatedPost);
        Navigator.of(context).pop(updatedPost);
        AppSnackBar.success(context, 'Post updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        AppSnackBar.error(
          context,
          'Failed to update post: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTypography.bodyRegular),
        ),
        leadingWidth: 70,
        title: Text('Edit Post', style: AppTypography.headlineMd),
        centerTitle: true,
        actions: [
          _isSaving
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
                  onPressed: _savePost,
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Text('Photos', style: AppTypography.bodyBold),
                const Spacer(),
                Text(
                  '$_totalImageCount/10',
                  style: AppTypography.captionTimestamp,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 108,
            child: _loadingImages && _existingImages.isEmpty
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [
                      ...List.generate(_existingImages.length, (index) {
                        final img = _existingImages[index];
                        return _ImageThumb(
                          onRemove: () => _removeExisting(index),
                          child: Image.network(
                            img.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.surfaceTertiary,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                      ...List.generate(_newFiles.length, (index) {
                        final file = _newFiles[index];
                        return _ImageThumb(
                          onRemove: () => _removeNew(index),
                          badge: 'New',
                          child: Image.file(file, fit: BoxFit.cover),
                        );
                      }),
                      if (_totalImageCount < 10) ...[
                        _AddThumb(
                          icon: Icons.add_photo_alternate_outlined,
                          label: 'Gallery',
                          onTap: _pickImages,
                        ),
                        _AddThumb(
                          icon: Icons.photo_camera_outlined,
                          label: 'Camera',
                          onTap: _pickCameraImage,
                        ),
                      ],
                    ],
                  ),
          ),
          if (!_loadingImages && !_hasMediaIds && _existingImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Text(
                'Showing current photos. Add or replace photos to update media.',
                style: AppTypography.captionTimestamp,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                NetworkImage(widget.post.user.avatarUrl),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.post.user.username,
                            style: AppTypography.bodySmBold,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Author',
                              style: AppTypography.captionTimestamp
                                  .copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _captionController,
                        maxLines: 4,
                        maxLength: 2200,
                        style: AppTypography.bodyRegular,
                        decoration: InputDecoration(
                          hintText: 'Write a caption for your cat post...',
                          hintStyle: AppTypography.bodyRegular
                              .copyWith(color: AppColors.textPlaceholder),
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_captionController.text.length}/2,200',
                          style: AppTypography.captionTimestamp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: AiCaptionGenerateButton(
              enabled: _totalImageCount > 0 &&
                  !_isSaving &&
                  !_isGeneratingCaption,
              loading: _isGeneratingCaption,
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
          const SizedBox(height: 12),
          const Divider(height: 0.8, color: AppColors.borderSubtle),

          ListTile(
            leading: const Icon(Icons.pets, color: AppColors.primary, size: 20),
            title: Text('Tag Cats & Friends', style: AppTypography.bodyBold),
            subtitle: Text(
              _taggedUsernames.isEmpty
                  ? 'Tag people in your post'
                  : _taggedUsernames.map((u) => '@$u').join(', '),
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
            title: Text('Location', style: AppTypography.bodyBold),
            subtitle: Text(
              _location.isEmpty ? 'Add a location' : _location,
              style: AppTypography.bodySm,
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _pickLocation,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  final String? badge;

  const _ImageThumb({
    required this.child,
    required this.onRemove,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: child,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddThumb extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddThumb({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
            color: AppColors.surfaceSecondary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 6),
              Text(label, style: AppTypography.captionTimestamp),
            ],
          ),
        ),
      ),
    );
  }
}
