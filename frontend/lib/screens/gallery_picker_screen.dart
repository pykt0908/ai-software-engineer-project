import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_snackbar.dart';

/// Instagram-style gallery picker. Returns selected [File]s (max 10) or null if cancelled.
class GalleryPickerScreen extends StatefulWidget {
  final int maxImages;
  final List<File>? initialFiles;

  const GalleryPickerScreen({
    super.key,
    this.maxImages = 10,
    this.initialFiles,
  });

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  final ImagePicker _cameraPicker = ImagePicker();

  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  List<AssetEntity> _assets = [];
  final List<AssetEntity> _selected = [];
  AssetEntity? _previewAsset;
  File? _previewFile;

  bool _loading = true;
  bool _multiSelect = true;
  bool _permissionDenied = false;
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  static const _bg = Color(0xFF000000);
  static const _bar = Color(0xFF1C1C1E);
  static const _gridGap = 1.5;

  @override
  void initState() {
    super.initState();
    _initGallery();
  }

  Future<void> _initGallery() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (!state.hasAccess) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
      }
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (!mounted) return;

    if (albums.isEmpty) {
      setState(() {
        _albums = [];
        _loading = false;
      });
      return;
    }

    _albums = albums;
    _currentAlbum = albums.first;
    await _loadAssets(reset: true);
  }

  Future<void> _loadAssets({bool reset = false}) async {
    final album = _currentAlbum;
    if (album == null) return;

    if (reset) {
      _page = 0;
      _hasMore = true;
      _assets = [];
    }
    if (!_hasMore) return;

    setState(() {
      if (reset) _loading = true;
      _loadingMore = !reset;
    });

    final pageSize = 60;
    final next = await album.getAssetListPaged(page: _page, size: pageSize);
    if (!mounted) return;

    setState(() {
      _assets.addAll(next);
      _hasMore = next.length >= pageSize;
      _page += 1;
      _loading = false;
      _loadingMore = false;

      if (_previewAsset == null && _assets.isNotEmpty) {
        _setPreview(_assets.first, autoSelectIfEmpty: true);
      }
    });
  }

  Future<void> _setPreview(
    AssetEntity asset, {
    bool autoSelectIfEmpty = false,
  }) async {
    setState(() {
      _previewAsset = asset;
      _previewFile = null;
    });

    if (autoSelectIfEmpty && _selected.isEmpty && !_multiSelect) {
      _selected.add(asset);
    } else if (autoSelectIfEmpty && _selected.isEmpty && _multiSelect) {
      // Preview only until user taps; keep first as soft preview
    }

    final file = await asset.file;
    if (!mounted || _previewAsset?.id != asset.id) return;
    setState(() => _previewFile = file);
  }

  void _toggleSelect(AssetEntity asset) {
    setState(() {
      final index = _selected.indexWhere((a) => a.id == asset.id);
      if (index >= 0) {
        _selected.removeAt(index);
        if (_previewAsset?.id == asset.id) {
          if (_selected.isNotEmpty) {
            _setPreview(_selected.last);
          }
        }
      } else {
        if (_selected.length >= widget.maxImages) {
          AppSnackBar.info(
            context,
            'Maximum ${widget.maxImages} photos allowed',
          );
          return;
        }
        if (!_multiSelect) {
          _selected
            ..clear()
            ..add(asset);
        } else {
          _selected.add(asset);
        }
        _setPreview(asset);
      }
    });
  }

  void _onAssetTap(AssetEntity asset) {
    if (_multiSelect) {
      _toggleSelect(asset);
    } else {
      setState(() {
        _selected
          ..clear()
          ..add(asset);
      });
      _setPreview(asset);
    }
  }

  Future<void> _openCamera() async {
    try {
      final photo = await _cameraPicker.pickImage(source: ImageSource.camera);
      if (photo == null || !mounted) return;
      final file = File(photo.path);
      if (_selected.length >= widget.maxImages && _multiSelect) {
        AppSnackBar.info(context, 'Maximum ${widget.maxImages} photos allowed');
        return;
      }
      setState(() {
        _previewAsset = null;
        _previewFile = file;
      });
      // Camera shots are returned as files directly on Next via _cameraExtraFiles
      _cameraExtraFiles.add(file);
      if (!_multiSelect) {
        _selected.clear();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Could not open camera: $e');
      }
    }
  }

  final List<File> _cameraExtraFiles = [];

  Future<void> _pickAlbum() async {
    if (_albums.isEmpty) return;
    final chosen = await showModalBottomSheet<AssetPathEntity>(
      context: context,
      backgroundColor: _bar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _albums.length,
            itemBuilder: (context, i) {
              final album = _albums[i];
              final selected = album.id == _currentAlbum?.id;
              return ListTile(
                title: Text(
                  album.name.isEmpty ? 'Recents' : album.name,
                  style: AppTypography.bodyBold.copyWith(color: Colors.white),
                ),
                trailing: selected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, album),
              );
            },
          ),
        );
      },
    );

    if (chosen == null || !mounted) return;
    setState(() {
      _currentAlbum = chosen;
      _previewAsset = null;
      _previewFile = null;
    });
    await _loadAssets(reset: true);
  }

  Future<void> _onNext() async {
    final nav = Navigator.of(context);
    final files = <File>[];

    for (final asset in _selected) {
      final file = await asset.file;
      if (file != null) files.add(file);
    }
    for (final cam in _cameraExtraFiles) {
      if (!files.any((f) => f.path == cam.path)) {
        files.add(cam);
      }
    }

    // If nothing selected but preview exists, use preview
    if (files.isEmpty && _previewFile != null) {
      files.add(_previewFile!);
    }

    if (!mounted) return;

    if (files.isEmpty) {
      AppSnackBar.info(context, 'Select at least 1 photo');
      return;
    }

    if (files.length > widget.maxImages) {
      files.removeRange(widget.maxImages, files.length);
    }

    nav.pop(files);
  }

  int? _selectionNumber(AssetEntity asset) {
    final i = _selected.indexWhere((a) => a.id == asset.id);
    return i >= 0 ? i + 1 : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildPreview(),
            _buildAlbumBar(),
            Expanded(child: _buildBody()),
            _buildModePill(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final canNext =
        _selected.isNotEmpty || _previewFile != null || _cameraExtraFiles.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 26),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            Expanded(
              child: Text(
                'New Post',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ),
            TextButton(
              onPressed: canNext ? _onNext : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    canNext ? AppColors.primary : Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white38,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Next',
                style: AppTypography.bodyBold.copyWith(
                  color: canNext ? Colors.white : Colors.white38,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    Widget content;
    if (_previewFile != null) {
      content = Image.file(_previewFile!, fit: BoxFit.cover);
    } else if (_loading) {
      content = const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      );
    } else {
      content = Container(
        color: const Color(0xFF111111),
        child: const Center(
          child: Icon(Icons.photo_outlined, color: Colors.white24, size: 48),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.open_in_full,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumBar() {
    final albumName = _currentAlbum?.name.isNotEmpty == true
        ? _currentAlbum!.name
        : 'Recents';

    return Container(
      height: 44,
      color: _bg,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAlbum,
            child: Row(
              children: [
                Text(
                  albumName,
                  style: AppTypography.bodyBold.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _multiSelect = !_multiSelect;
                if (!_multiSelect && _selected.length > 1) {
                  final last = _selected.last;
                  _selected
                    ..clear()
                    ..add(last);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _multiSelect ? const Color(0xFF3A3A3C) : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.collections,
                    size: 16,
                    color: _multiSelect ? AppColors.primary : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Select',
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                'Photo access is required to create a post.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => PhotoManager.openSetting(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      );
    }

    // +1 for camera tile
    final itemCount = _assets.length + 1;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240 &&
            !_loadingMore &&
            _hasMore) {
          _loadAssets();
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: _gridGap,
          crossAxisSpacing: _gridGap,
        ),
        itemCount: itemCount + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: _openCamera,
              child: Container(
                color: const Color(0xFF2C2C2E),
                child: const Icon(Icons.camera_alt, color: Colors.white70, size: 28),
              ),
            );
          }

          final assetIndex = index - 1;
          if (assetIndex >= _assets.length) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final asset = _assets[assetIndex];
          final number = _selectionNumber(asset);
          final isPreview = _previewAsset?.id == asset.id;

          return _AssetThumb(
            asset: asset,
            selectionNumber: number,
            dimmed: isPreview && number == null,
            onTap: () => _onAssetTap(asset),
          );
        },
      ),
    );
  }

  Widget _buildModePill() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _modeChip('POST', selected: true, onTap: () {}),
              _modeChip('STORY', onTap: () {
                AppSnackBar.info(context, 'Stories coming soon');
              }),
              _modeChip('REELS', onTap: () {
                AppSnackBar.info(context, 'Reels coming soon');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeChip(String label, {bool selected = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _AssetThumb extends StatefulWidget {
  final AssetEntity asset;
  final int? selectionNumber;
  final bool dimmed;
  final VoidCallback onTap;

  const _AssetThumb({
    required this.asset,
    required this.selectionNumber,
    required this.dimmed,
    required this.onTap,
  });

  @override
  State<_AssetThumb> createState() => _AssetThumbState();
}

class _AssetThumbState extends State<_AssetThumb> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AssetThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final data = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize(300, 300),
    );
    if (!mounted) return;
    setState(() => _bytes = data);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectionNumber != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_bytes != null)
            Image.memory(_bytes!, fit: BoxFit.cover)
          else
            Container(color: const Color(0xFF1C1C1E)),
          if (widget.dimmed || selected)
            Container(
              color: Colors.black.withValues(alpha: selected ? 0.35 : 0.45),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF4EA8DE) : Colors.black38,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: selected
                  ? Text(
                      '${widget.selectionNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
