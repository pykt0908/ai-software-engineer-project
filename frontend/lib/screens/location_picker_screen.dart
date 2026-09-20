import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/api_config.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_snackbar.dart';

/// Full-screen map / places location picker. Returns a place label,
/// empty string to clear, or null if cancelled.
class LocationPickerScreen extends StatefulWidget {
  final String current;

  const LocationPickerScreen({super.key, this.current = ''});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _defaultCenter = LatLng(13.7563, 100.5018); // Bangkok

  GoogleMapController? _mapController;
  final _searchController = TextEditingController();
  final _customController = TextEditingController();

  LatLng _pin = _defaultCenter;
  String _placeLabel = '';
  bool _resolving = false;
  bool _locating = false;
  bool _searching = false;
  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.current.isNotEmpty) {
      _placeLabel = widget.current;
      _customController.text = widget.current;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _customController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final point = await LocationService.instance.getCurrentLatLng();
      if (!mounted) return;
      setState(() => _pin = point);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(point, 16),
      );
      await _resolvePin(point);
    } catch (_) {
      if (widget.current.isEmpty && mounted) {
        await _resolvePin(_pin);
      }
    }
  }

  Future<void> _resolvePin(LatLng point) async {
    setState(() => _resolving = true);
    try {
      final label = await LocationService.instance.reverseGeocode(point);
      if (!mounted) return;
      setState(() {
        _placeLabel = label;
        _customController.text = label;
        _resolving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _placeLabel =
            '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
        _customController.text = _placeLabel;
        _resolving = false;
      });
    }
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final point = await LocationService.instance.getCurrentLatLng();
      if (!mounted) return;
      setState(() {
        _pin = point;
        _locating = false;
        _suggestions = [];
        _searchController.clear();
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(point, 16),
      );
      await _resolvePin(point);
    } catch (e) {
      if (!mounted) return;
      setState(() => _locating = false);
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _pin = point;
      _suggestions = [];
    });
    _resolvePin(point);
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    try {
      final results = await LocationService.instance.searchPlaces(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _searching = false;
      });
    }
  }

  void _selectSuggestion(PlaceSuggestion place) {
    Navigator.pop(context, place.label);
  }

  void _confirm() {
    final custom = _customController.text.trim();
    final label = custom.isNotEmpty ? custom : _placeLabel.trim();
    Navigator.pop(context, label);
  }

  void _clear() => Navigator.pop(context, '');

  (String, String) _splitPlaceLabel(String label) {
    if (label.contains('(') && label.endsWith(')')) {
      final idx = label.indexOf('(');
      final title = label.substring(0, idx).trim();
      final sub = label.substring(idx + 1, label.length - 1).trim();
      return (title, sub);
    }
    final commaIdx = label.indexOf(',');
    if (commaIdx != -1) {
      final title = label.substring(0, commaIdx).trim();
      final sub = label.substring(commaIdx + 1).trim();
      return (title, sub);
    }
    return (label, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCanvas,
        elevation: 0,
        title: Text('Add Location', style: AppTypography.headlineMd),
        actions: [
          TextButton(
            onPressed: _clear,
            child: Text(
              'Clear',
              style: AppTypography.bodyBold.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _confirm,
            child: Text(
              'Done',
              style: AppTypography.bodyBold.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places, cafes, landmarks...',
                hintStyle: AppTypography.bodyRegular
                    .copyWith(color: AppColors.textPlaceholder),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : (_searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _suggestions = [];
                                _searching = false;
                              });
                            },
                          )
                        : null),
                filled: true,
                fillColor: AppColors.surfaceSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (q) {
                setState(() {});
                _onSearchChanged(q);
              },
            ),
          ),

          // Main Content
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final query = _searchController.text.trim();
    final isSearchingMode = query.isNotEmpty || _searching || _suggestions.isNotEmpty;

    if (isSearchingMode) {
      return _buildSearchResults(query);
    }

    final hasMapKey = ApiConfig.googleMapsApiKey.isNotEmpty;
    if (hasMapKey) {
      return _buildMapWithControls();
    } else {
      return _buildNoMapContent();
    }
  }

  Widget _buildSearchResults(String query) {
    if (_searching && _suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Searching places...',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_suggestions.isEmpty && query.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_outlined,
                size: 48,
                color: AppColors.textPlaceholder,
              ),
              const SizedBox(height: 12),
              Text(
                'No places found for "$query"',
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, query);
                },
                icon: const Icon(Icons.check, size: 18),
                label: Text('Use "$query" as location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _suggestions.length + (query.isNotEmpty ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: AppColors.borderSubtle,
      ),
      itemBuilder: (context, index) {
        if (query.isNotEmpty && index == 0) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_location_alt_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            title: Text(
              'Use "$query"',
              style: AppTypography.bodyBold.copyWith(color: AppColors.primary),
            ),
            subtitle: Text(
              'Custom location name',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            trailing: const Icon(
              Icons.check,
              color: AppColors.primary,
              size: 20,
            ),
            onTap: () => Navigator.pop(context, query),
          );
        }

        final suggestionIndex = query.isNotEmpty ? index - 1 : index;
        final place = _suggestions[suggestionIndex];
        final (title, subtitle) = _splitPlaceLabel(place.label);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceTertiary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.place_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: AppTypography.bodyBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(
                  subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textPlaceholder,
            size: 18,
          ),
          onTap: () => _selectSuggestion(place),
        );
      },
    );
  }

  Widget _buildNoMapContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Current Location Tile
        InkWell(
          onTap: _locating ? null : _useMyLocation,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCanvas,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _locating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.my_location, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use Current Location',
                        style: AppTypography.bodyBold,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _resolving
                            ? 'Detecting your location...'
                            : (_placeLabel.isNotEmpty
                                ? _placeLabel
                                : 'Tap to detect nearby place'),
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_placeLabel.isNotEmpty && !_resolving)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Custom Place Name Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCanvas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Custom Place Name',
                    style: AppTypography.bodyBold,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Type a custom location name or edit the detected place:',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customController,
                decoration: InputDecoration(
                  hintText: 'e.g. My Home, Office, Central World...',
                  hintStyle: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textPlaceholder,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {
                    _placeLabel = val;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Friendly tip card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search any place (shops, cafes, malls) in the search bar above to view full-page results and choose instantly.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapWithControls() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _pin,
            zoom: 14,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: _onMapTap,
          markers: {
            Marker(
              markerId: const MarkerId('selected_pin'),
              position: _pin,
            ),
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        Positioned(
          right: 16,
          bottom: 110,
          child: FloatingActionButton.extended(
            onPressed: _locating ? null : _useMyLocation,
            backgroundColor: AppColors.surfaceCanvas,
            foregroundColor: AppColors.primary,
            elevation: 2,
            icon: _locating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              'My location',
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCanvas,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _resolving
                            ? Text(
                                'Finding place name...',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              )
                            : Text(
                                _placeLabel.isEmpty
                                    ? 'Tap the map to pick a place'
                                    : _placeLabel,
                                style: AppTypography.bodyBold,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customController,
                    decoration: InputDecoration(
                      hintText: 'Edit place name...',
                      hintStyle: AppTypography.bodyRegular
                          .copyWith(color: AppColors.textPlaceholder),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
