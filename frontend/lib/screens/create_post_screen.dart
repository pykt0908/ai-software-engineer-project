import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CreatePostScreen extends StatefulWidget {
  final Function(Post)? onPostCreated;

  const CreatePostScreen({super.key, this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];
  int _currentImageIndex = 0;
  bool _isSharing = false;
  int _selectedFilterIndex = 0;
  final String _selectedLocation = 'Tokyo, Japan';
  final String _taggedCats = '@biscuit_paw';

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'colorFilter': null},
    {'name': 'Warm Glow', 'colorFilter': ColorFilter.mode(Colors.orange.withValues(alpha: 0.15), BlendMode.colorBurn)},
    {'name': 'Golden Hour', 'colorFilter': ColorFilter.mode(Colors.amber.withValues(alpha: 0.2), BlendMode.overlay)},
    {'name': 'Vintage Cat', 'colorFilter': ColorFilter.mode(Colors.brown.withValues(alpha: 0.2), BlendMode.multiply)},
    {'name': 'Soft Purr', 'colorFilter': ColorFilter.mode(Colors.pink.withValues(alpha: 0.1), BlendMode.softLight)},
  ];

  final List<String> _suggestedHashtags = [
    '#CatLife',
    '#Purrfect',
    '#Meow',
    '#KittenLovers',
    '#Loaf',
    '#Caturday',
    '#Ragdoll',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          for (final xfile in picked) {
            if (_selectedFiles.length < 10) {
              _selectedFiles.add(File(xfile.path));
            }
          }
        });
        if (picked.length + _selectedFiles.length > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 10 photos allowed per post')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _pickCameraImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          if (_selectedFiles.length < 10) {
            _selectedFiles.add(File(photo.path));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening camera: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      if (_currentImageIndex >= _selectedFiles.length && _selectedFiles.isNotEmpty) {
        _currentImageIndex = _selectedFiles.length - 1;
      }
    });
  }

  void _addHashtag(String tag) {
    setState(() {
      if (_captionController.text.isEmpty) {
        _captionController.text = tag;
      } else {
        _captionController.text = '${_captionController.text} $tag';
      }
    });
  }

  Future<void> _handleShare() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 cat photo to share'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      // 1. Upload compressed images to Strapi
      final imageIds = await PostService().uploadImages(_selectedFiles);

      // 2. Create the post
      final caption = _captionController.text.trim();
      final newPost = await PostService().createPost(
        caption: caption.isNotEmpty ? caption : 'Enjoying my day with lots of purrs! 🐾',
        imageIds: imageIds,
      );

      if (mounted) {
        setState(() {
          _isSharing = false;
        });

        widget.onPostCreated?.call(newPost);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Your cat post has been published!'),
              ],
            ),
          ),
        );
        Navigator.of(context).maybePop(newPost);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish post: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser ?? MockData.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _isSharing ? null : () => Navigator.of(context).maybePop(),
          child: Text(
            'Cancel',
            style: AppTypography.bodyRegular.copyWith(color: AppColors.textPrimary),
          ),
        ),
        leadingWidth: 70,
        title: Text(
          'New Post',
          style: AppTypography.headlineMd,
        ),
        centerTitle: true,
        actions: [
          _isSharing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
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
          // 1:1 Image Preview Area
          AspectRatio(
            aspectRatio: 1.0,
            child: _selectedFiles.isEmpty
                ? Container(
                    color: AppColors.surfaceSecondary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 56, color: AppColors.primary),
                        const SizedBox(height: 12),
                        Text(
                          'Select Cat Photos (1–10)',
                          style: AppTypography.headlineMd.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPEG/PNG • Auto-compressed',
                          style: AppTypography.captionTimestamp,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.photo_library, size: 18),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _pickCameraImage,
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text('Camera'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.borderMuted),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: _filters[_selectedFilterIndex]['colorFilter'] ??
                            const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: PageView.builder(
                          itemCount: _selectedFiles.length,
                          onPageChanged: (i) => setState(() => _currentImageIndex = i),
                          itemBuilder: (ctx, i) {
                            return Image.file(
                              _selectedFiles[i],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      // Image Count Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1} / ${_selectedFiles.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      // Remove current photo button
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
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      // Add More Photos Button
                      if (_selectedFiles.length < 10)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add More'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withValues(alpha: 0.7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),

          // Filters Selector
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceCanvas,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _filters[index]['name'] as String,
                        style: AppTypography.labelSm.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 0.8, color: AppColors.borderSubtle),

          // Caption & Author Row
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
                      hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.textPlaceholder),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: AppTypography.bodyRegular,
                  ),
                ),
              ],
            ),
          ),

          // Quick Hashtag Suggestion Tray
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
                  children: _suggestedHashtags.map((tag) {
                    return GestureDetector(
                      onTap: () => _addHashtag(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTertiary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.primary,
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

          // Community Metadata Rows
          ListTile(
            leading: const Icon(Icons.pets, color: AppColors.primary, size: 20),
            title: Text('Tag Cats & Friends', style: AppTypography.bodyBold),
            subtitle: Text(_taggedCats, style: AppTypography.bodySm.copyWith(color: AppColors.primary)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.person_add, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Tagging friends enabled'),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 0.8, indent: 50, color: AppColors.borderSubtle),

          ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
            title: Text('Add Location', style: AppTypography.bodyBold),
            subtitle: Text(_selectedLocation, style: AppTypography.bodySm),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Location selected: Tokyo, Japan'),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 0.8, indent: 50, color: AppColors.borderSubtle),

          ListTile(
            leading: const Icon(Icons.tune, color: AppColors.textSecondary, size: 20),
            title: Text('Advanced Settings', style: AppTypography.bodyRegular),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {},
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
