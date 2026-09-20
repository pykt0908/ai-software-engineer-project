import 'dart:async';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/location_picker_screen.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

const List<String> kSuggestedHashtags = [
  '#CatLife',
  '#Purrfect',
  '#Meow',
  '#KittenLovers',
  '#Loaf',
  '#Caturday',
  '#Ragdoll',
  '#CatCafe',
  '#Whiskers',
];

String appendHashtagToCaption(String caption, String tag) {
  final normalized = tag.startsWith('#') ? tag : '#$tag';
  final parts = caption
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  final exists = parts.any((p) => p.toLowerCase() == normalized.toLowerCase());
  if (exists) {
    return parts.where((p) => p.toLowerCase() != normalized.toLowerCase()).join(' ');
  }
  if (caption.trim().isEmpty) return normalized;
  return '${caption.trim()} $normalized';
}

Future<String?> showLocationPickerSheet(
  BuildContext context, {
  required String current,
}) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => LocationPickerScreen(current: current),
    ),
  );
}

Future<List<String>?> showTagFriendsSheet(
  BuildContext context, {
  required List<String> current,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceCanvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _TagFriendsSheet(current: current),
  );
}

class _TagFriendsSheet extends StatefulWidget {
  final List<String> current;

  const _TagFriendsSheet({required this.current});

  @override
  State<_TagFriendsSheet> createState() => _TagFriendsSheetState();
}

class _TagFriendsSheetState extends State<_TagFriendsSheet> {
  late final TextEditingController _searchController;
  late final List<String> _selected;
  List<CatUser> _results = [];
  bool _searching = false;
  Timer? _debounce;
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected = List<String>.from(widget.current);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }

    final token = ++_searchToken;
    setState(() => _searching = true);

    try {
      final users = await ProfileService().searchUsers(query);
      if (!mounted || token != _searchToken) return;
      setState(() {
        _results = users;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || token != _searchToken) return;
      setState(() {
        _results = [];
        _searching = false;
      });
    }
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _runSearch(q));
  }

  void _toggleUser(CatUser user) {
    final username = user.username.trim();
    if (username.isEmpty) return;

    setState(() {
      if (_selected.contains(username)) {
        _selected.remove(username);
      } else if (_selected.length < 20) {
        _selected.add(username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Tag Cats & Friends', style: AppTypography.headlineMd),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: AppTypography.bodyRegular
                    .copyWith(color: AppColors.textPlaceholder),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
              ),
              onChanged: _onQueryChanged,
            ),
            if (_selected.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selected.map((name) {
                  return InputChip(
                    label: Text('@$name'),
                    onDeleted: () {
                      setState(() => _selected.remove(name));
                    },
                    backgroundColor: AppColors.surfaceTertiary,
                    deleteIconColor: AppColors.textSecondary,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _searching
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.trim().isEmpty
                                ? 'Search for friends to tag'
                                : 'No users found',
                            style: AppTypography.bodyRegular
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final user = _results[index];
                            final isSelected =
                                _selected.contains(user.username);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.surfaceTertiary,
                                backgroundImage: user.avatarUrl.isNotEmpty
                                    ? NetworkImage(user.avatarUrl)
                                    : null,
                                child: user.avatarUrl.isEmpty
                                    ? const Icon(Icons.person,
                                        color: AppColors.textSecondary)
                                    : null,
                              ),
                              title: Text(
                                user.username,
                                style: AppTypography.bodyBold,
                              ),
                              subtitle: Text(
                                user.displayName,
                                style: AppTypography.captionTimestamp,
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                color: AppColors.primary,
                              ),
                              onTap: () => _toggleUser(user),
                            );
                          },
                        ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, List<String>.from(_selected)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selected.isEmpty
                    ? 'Done'
                    : 'Done (${_selected.length} tagged)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
