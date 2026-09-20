import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_snackbar.dart';

/// Normalize a user-entered website into a loadable https URL.
String normalizeWebsiteUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}

/// Opens [url] in an in-app WebView browser.
Future<void> openInAppBrowser(
  BuildContext context, {
  required String url,
  String? title,
}) async {
  final normalized = normalizeWebsiteUrl(url);
  if (normalized.isEmpty) return;

  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    AppSnackBar.error(context, 'Invalid link');
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => InAppBrowserScreen(
        initialUrl: uri.toString(),
        title: title,
      ),
    ),
  );
}

class InAppBrowserScreen extends StatefulWidget {
  final String initialUrl;
  final String? title;

  const InAppBrowserScreen({
    super.key,
    required this.initialUrl,
    this.title,
  });

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _progress = 0;
  var _pageTitle = '';
  var _currentUrl = '';
  var _canGoBack = false;
  var _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _pageTitle = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : _hostOf(widget.initialUrl);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.surfaceCanvas)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress;
              _loading = progress < 100;
            });
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _currentUrl = url;
              _loading = true;
            });
            _refreshNavState();
          },
          onPageFinished: (url) async {
            if (!mounted) return;
            final title = await _controller.getTitle();
            setState(() {
              _currentUrl = url;
              _loading = false;
              if (title != null && title.trim().isNotEmpty) {
                _pageTitle = title.trim();
              } else {
                _pageTitle = _hostOf(url);
              }
            });
            _refreshNavState();
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _refreshNavState() async {
    final back = await _controller.canGoBack();
    final forward = await _controller.canGoForward();
    if (!mounted) return;
    setState(() {
      _canGoBack = back;
      _canGoForward = forward;
    });
  }

  String _hostOf(String url) {
    final uri = Uri.tryParse(url);
    return uri?.host.isNotEmpty == true ? uri!.host : url;
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(_currentUrl.isNotEmpty ? _currentUrl : widget.initialUrl);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      AppSnackBar.error(context, 'Could not open external browser');
    }
  }

  Future<void> _reload() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    // WebView is not supported well on Flutter web in this project setup.
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.surfaceCanvas,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCanvas,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(_pageTitle, style: AppTypography.headlineMd),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'In-app browser is available on iOS / Android.',
                  style: AppTypography.bodyRegular,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openExternally,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open in browser'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pageTitle,
              style: AppTypography.bodyBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _hostOf(_currentUrl.isNotEmpty ? _currentUrl : widget.initialUrl),
              style: AppTypography.captionTimestamp.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _reload,
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: AppColors.textPrimary),
            onPressed: _openExternally,
            tooltip: 'Open externally',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _loading
              ? LinearProgressIndicator(
                  value: _progress > 0 && _progress < 100 ? _progress / 100 : null,
                  minHeight: 2,
                  color: AppColors.primary,
                  backgroundColor: AppColors.borderSubtle,
                )
              : const SizedBox(height: 2),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle),
                ),
                color: AppColors.surfaceCanvas,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: _canGoBack
                          ? AppColors.textPrimary
                          : AppColors.textPlaceholder,
                    ),
                    onPressed: _canGoBack
                        ? () async {
                            await _controller.goBack();
                            _refreshNavState();
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: _canGoForward
                          ? AppColors.textPrimary
                          : AppColors.textPlaceholder,
                    ),
                    onPressed: _canGoForward
                        ? () async {
                            await _controller.goForward();
                            _refreshNavState();
                          }
                        : null,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _openExternally,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text('Safari / Chrome', style: AppTypography.bodySmBold),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
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
}
