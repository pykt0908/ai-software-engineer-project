import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../services/api_config.dart';
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

  // Web-specific gallery state
  final List<String> _webImages = [];
  final List<String> _selectedWebImages = [];
  String? _previewWebUrl;

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
    if (kIsWeb) {
      _initWebGallery();
      return;
    }

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

  void _initWebGallery() {
    final sampleUrls = [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD_GWNiPrv6ef4Zg1hl57wslNmd_9SxjRtsOAhhRMS3ZElZf5KT8MiAZDgvNiO2Sn6kT5bS24xHLgkbhPEEVF4ri87Y48FjSAxOcPmNp7He80fCfKD7JgrC9twIwkoXLu1QGOt1UiThGXnB7cxW23PUetH_yMvcamiSOxE-YPi2MiILWGfTr9MveQ6jO86AeDvsBFGb0Ta5P9qb1HiG1sV4lfSzUwv6H-BJdeHVYIVpHz-dVVsi4WY4Lw',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB49A1ML0Ok0tP0-bQom7LQzwuOMr4u9KFWaNcrE8lWjg3zYtFXQ26GpOgn-gfZKAc_RabLxZvOt2mnGNpHDhCG5x_9UekW9Y9mBCLUNggn3rjb3UJJs7KygRXQvtA_J24vdUKdXwI6gnRjPsYJgiJfIpXFct1SMn6i-2Lfec09dIp-6xLdV8jTeSqoLV6C9NcMA73Bt7_v0CaLZAUVACtIg0cgHmrA0_aO8Ne9Wirr0_QHSeQw1APrCw',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDqvlv_Q1vj1FDF9B1SH10P8obnajjqh4-xicqYNnfopI7q-PIHWTVT5pkPj3WEq1kocGVKD3_nKfbZjY-hShlkoefPpAF22lKGqBvgxMTVtGDT6tXc1jmwdqFwhl-e2tTXJAUdCU_CUKfyu6nvajd-bOjCe5SM3pjbwh8V4p9OIhhHiQCAMf0fdCdUaf2E16qGLnF8ASCP-j6wpNUyB8VeiYHwFnDCDZNLdw7ZEGHUArBhedqR4WiG7g',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAlfFPNSwtQNnj_tZ0XqC3HaLHCMBsfWek2hvKjBPL2IQOYeIYcU9oz94ubOXuyL7LA1slKTUgvQBMtPtb5DPqACfwsJnzDuGC6WPmKIywHE1Y41oWShx_TtzFALbslhuCB72xBGeP1ev0l0ysbHFLtE--HSY6AEg8WTNMhdh7CmyRgHYj32uLvAqnKhZnajCJbLMz4UqdNvUGoANqxtCg3ZSOpVbrWB_-HBjMVt_gOiqMtP9v6U-I3uA',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBr_cpvQTDpVyvAcHfJUaLwJ7iRJzucQth5zyU63zaMrT6bqp9vwjowYL9QC5JPICqLP31Ryams9nEcr-pHvi3hTS3wxM-T7dAm2eT99X6dujNwczSUUAvmoIoWPpAd65_d8aVXqw9V5ZqVhmF4jF3d1hFxr4Td5Dk_7SVO9dal15f97o1OGhtgObXZUp40CjWaqb6yOHQEx7x81gJawtn4vwmg2IAXuO2fb_d99SQy3alqR-4ij1NVNg',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBYqLS69lodFY-q-5bue5dIcGT2TTtsISNrTR4XU6hAK1vQJVEEgPKNPLmYbeLNvFagGx7DN17zLqJTb4hX46Kwo0laxTjAJIASgpjRggozgdZnKk3-T4tBG2Df3fKD6Kd7a9ibWG4T7-MIKLpltiRsuyGaRLl-UjFtOvA3fIOhgMo27NfQUqCjKZIDZaZTqwZfn0_s9qlserH-P7WgfZ5JLEVv72CBWSrz-LT4MCwt4-cwf3a_5i2KTQ',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC2Wf-DMyLU3-9qmMxKB5jlTGJ2qSUhVhpWBpf0fkIUqrWKqB03M-oRmxspBwsFWe_Ox6XuYG3jO7vDC1-l4V0NDghBNeHPSXy8pEVK8wbGKJEXpOse5wBrurSb4aX6pTfQRupM-U3Ssoa5DFsjW2XgITHBiqAEWVZOf7YRyq6cC3_KRM2tH7gxmWy6lztiOZ6ZPBYrmNX8Nu-gp7e8QTb4bkkDlKCGU1RrFpEjk9Dp7CCiM9TuI3iCHQ',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAyY6KCMCY5yTKXBYaYJebYkLsqwGKglyFSZZJSD2RQkB5cK9Cwjg8VWmTF2g6ocfO2tSs0WyfRJo3-ev_QIp51xMQOxG_JDbUN2cOH2bfw29V1MAdOTSe0PklgHnmf8MU1wX4sYCKo_OBRkAyS85agfWawQ0GIG79fUuD7yX0elBLUV2kwsgllVbF4h5l4YDCWWPFsEYNE7JDy9hr4gRuuwYil84vJ4H0dnbtEK45tA4GQ3krT9W7lSg',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC0XD-x0dfUjXw3MIH4Lhlyk6wMnHcQp-CBshOZ3azaTzmv0uS67O_9nIHwDGpP7lRmeFng2pWrK1mMwbMXMrGPi4PvSbqLIOCZnDBBbCRYzXuVkXH6NBAy19G-G1Cn3Wi-EAQUnaetj2Un35INsvDzibHUVTFn22q0uArSDNfmqjtFOijKJb2d3YQLmrCGC-FPdw7IQgqzgAVUPjnX8ISOjnzIW154VDqYeJmuKM9mzpg6272nT3s8-Q',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDfPZZBvk_nvpymjvlymjaX8o639vugOHBNFLexv54LTcTCk3kd_6iuzgcMgkcIo3VantYHBu8EItbvkOgYxoJeyC3DQyuCJPPyp1wEXYiF8u5aA5KkGM57fW-Pjayd0sltLaKhyXa1FgIFDDDfzE8uk2YzexO2eZiXLQ7ddEVjCJwzn6VRr7eROSX73DQETj-Hvzg3I9rN8HgojWroxJD1dpobfCo8jpQoLe4J0SOWpU-_Yi6x_G5qiQ',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDYq4h2lgrxJIUEMAoC2uufB-CBuWEEncgcLz6rY8IbnWIFba1UqWQSozpDJ6ssEQir-URYyxtVoQbNw4mdf_2FpgT7t5j7S-quf_r_tn4AoWc8Ey4880pnGnNds3P9U7VkULLxpAKOtwa2LBkcIJ7G4raeBX83K3b_0fsDI8YJXfSsihiM7Itglm9OwfQoyX-2SPfrQ4B26zK2ThXXzLgWKpLXmC8gGW3wlAlI7BEmClUY8YSQpitdgQ',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDgHq4gqaix1Z8C7wnrG9dw8dQcSa6fwprjccleQOkLGHiHDm_S23rtMaEWSa93Wgjp2ubKkH2fMNZKfI_udBUhr2bUkoz5rb49FiL0FlMYlg_f_ECWWkJb4VYQKqgGmIYkn7mZr0eqo-es1dmY3QvgM7Xd4jiKHlMBmP1pH4bJTNFUkJh0lbGFXhUXK6KsZPKrCpMMFU9l0ZB65hPiJWdCMMStFnaTeUM7_sSSEQbTxXiqTOsFryu3mw',
    ];

    if (!mounted) return;
    setState(() {
      _webImages.addAll(sampleUrls);
      _loading = false;
      if (_webImages.isNotEmpty) {
        _previewWebUrl = _webImages.first;
        _selectedWebImages.add(_webImages.first);
      }
    });
  }

  Future<void> _pickImagesWeb() async {
    try {
      final picked = await _cameraPicker.pickMultiImage(
        limit: widget.maxImages,
      );
      if (picked.isEmpty || !mounted) return;
      setState(() {
        for (final xf in picked) {
          _webImages.removeWhere((url) => url == xf.path);
          _webImages.insert(0, xf.path);
          if (_selectedWebImages.length < widget.maxImages) {
            _selectedWebImages.add(xf.path);
          }
        }
        if (_selectedWebImages.isNotEmpty) {
          _previewWebUrl = _selectedWebImages.last;
        } else if (_webImages.isNotEmpty) {
          _previewWebUrl = _webImages.first;
        }
      });
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Could not select photos: $e');
      }
    }
  }

  void _toggleSelectWeb(String url) {
    setState(() {
      final index = _selectedWebImages.indexOf(url);
      if (index >= 0) {
        _selectedWebImages.removeAt(index);
        if (_previewWebUrl == url) {
          if (_selectedWebImages.isNotEmpty) {
            _previewWebUrl = _selectedWebImages.last;
          }
        }
      } else {
        if (_selectedWebImages.length >= widget.maxImages) {
          AppSnackBar.info(context, 'Maximum ${widget.maxImages} photos allowed');
          return;
        }
        if (!_multiSelect) {
          _selectedWebImages.clear();
        }
        _selectedWebImages.add(url);
        _previewWebUrl = url;
      }
    });
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

    if (kIsWeb) {
      final toUse = _selectedWebImages.isNotEmpty
          ? _selectedWebImages
          : (_previewWebUrl != null ? [_previewWebUrl!] : <String>[]);
      for (final url in toUse) {
        files.add(File(url));
      }
      if (files.isEmpty) {
        AppSnackBar.info(context, 'Select at least 1 photo');
        return;
      }
      if (files.length > widget.maxImages) {
        files.removeRange(widget.maxImages, files.length);
      }
      nav.pop(files);
      return;
    }

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
    final canNext = kIsWeb
        ? (_selectedWebImages.isNotEmpty || _previewWebUrl != null)
        : (_selected.isNotEmpty || _previewFile != null || _cameraExtraFiles.isNotEmpty);
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
    if (kIsWeb) {
      if (_previewWebUrl != null) {
        content = Image.network(
          _previewWebUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF111111),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white24, size: 48),
            ),
          ),
        );
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
    } else if (_previewFile != null) {
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
    if (kIsWeb) {
      return Container(
        height: 44,
        color: _bg,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImagesWeb,
              icon: const Icon(Icons.add_photo_alternate, size: 16),
              label: const Text('Browse Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _multiSelect = !_multiSelect;
                  if (!_multiSelect && _selectedWebImages.length > 1) {
                    final last = _selectedWebImages.last;
                    _selectedWebImages
                      ..clear()
                      ..add(last);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _multiSelect ? AppColors.primary : const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.collections,
                      size: 16,
                      color: _multiSelect ? Colors.white : Colors.white70,
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
    if (kIsWeb) {
      if (_loading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        );
      }

      final itemCount = _webImages.length + 1;
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: _gridGap,
          crossAxisSpacing: _gridGap,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: _pickImagesWeb,
              child: Container(
                color: const Color(0xFF2C2C2E),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                    SizedBox(height: 4),
                    Text(
                      'Browse',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          final url = _webImages[index - 1];
          final selIndex = _selectedWebImages.indexOf(url);
          final isSelected = selIndex >= 0;
          final isPreview = _previewWebUrl == url;

          return GestureDetector(
            onTap: () {
              if (_multiSelect) {
                _toggleSelectWeb(url);
              } else {
                setState(() {
                  _selectedWebImages
                    ..clear()
                    ..add(url);
                  _previewWebUrl = url;
                });
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF222222),
                    child: const Icon(Icons.broken_image, color: Colors.white24),
                  ),
                ),
                if (isPreview && !isSelected)
                  Container(color: Colors.black.withValues(alpha: 0.35)),
                if (_multiSelect)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.4),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: isSelected
                          ? Text(
                              '${selIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

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
