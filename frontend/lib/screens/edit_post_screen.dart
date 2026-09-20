import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/post_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

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
  bool _isSaving = false;
  final List<Map<String, dynamic>> _quickIcons = [
    {'icon': Icons.pets, 'tag': '#paw'},
    {'icon': Icons.favorite, 'tag': '#love'},
    {'icon': Icons.wb_sunny, 'tag': '#sunbeam'},
    {'icon': Icons.auto_awesome, 'tag': '#vibes'},
    {'icon': Icons.camera_alt, 'tag': '#photo'},
    {'icon': Icons.music_note, 'tag': '#purr'},
    {'icon': Icons.local_dining, 'tag': '#treats'},
  ];

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    _location = widget.post.location;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedPost = await PostService().updatePost(
        documentId: widget.post.id,
        caption: _captionController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        widget.onPostUpdated?.call(updatedPost);
        Navigator.of(context).pop(updatedPost);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update post: $e'),
            backgroundColor: AppColors.error,
          ),
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
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
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
          // Post Thumbnail + Caption Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Read-only thumbnail with lock badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          widget.post.imageUrls.first,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 9),
                          SizedBox(width: 2),
                          Text(
                            'Original',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // User details + Caption textarea
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundImage: NetworkImage(widget.post.user.avatarUrl),
                          ),
                          const SizedBox(width: 6),
                          Text(widget.post.user.username, style: AppTypography.bodySmBold),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Author',
                              style: AppTypography.captionTimestamp.copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _captionController,
                        maxLines: 3,
                        maxLength: 2200,
                        style: AppTypography.bodyRegular,
                        decoration: InputDecoration(
                          hintText: 'Write a caption for your cat post...',
                          hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.textPlaceholder),
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

          // Quick Tags with Icons Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: AppColors.surfaceSecondary,
            child: Row(
              children: [
                const Icon(Icons.tag, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Quick Tags:',
                  style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickIcons.map((item) {
                        final icon = item['icon'] as IconData;
                        final tag = item['tag'] as String;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _captionController.text = '${_captionController.text} $tag';
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCanvas,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 13, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  tag,
                                  style: AppTypography.captionTimestamp.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.8, color: AppColors.borderSubtle),

          // Metadata rows
          ListTile(
            leading: const Icon(Icons.pets, color: AppColors.primary, size: 20),
            title: Text('Tag Cats & Friends', style: AppTypography.bodyBold),
            subtitle: Text('@biscuit_paw tagged', style: AppTypography.bodySm.copyWith(color: AppColors.primary)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {},
          ),
          const Divider(height: 0.8, indent: 50, color: AppColors.borderSubtle),

          ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
            title: Text('Location', style: AppTypography.bodyBold),
            subtitle: Text(_location, style: AppTypography.bodySm),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {},
          ),
          const Divider(height: 0.8, indent: 50, color: AppColors.borderSubtle),

          ListTile(
            leading: const Icon(Icons.accessibility_new, color: AppColors.textSecondary, size: 20),
            title: Text('Write Alt Text', style: AppTypography.bodyRegular),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
