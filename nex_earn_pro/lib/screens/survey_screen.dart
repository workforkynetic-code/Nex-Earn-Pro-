// File: lib/screens/survey_screen.dart
// Kaam: WebView se survey aur koi bhi web page dikhana
// Privacy Policy, Terms, Survey page sab isi screen se khulte hain

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';

class SurveyScreen extends StatefulWidget {
  final String url;
  final String title;

  const SurveyScreen({
    super.key,
    this.url = AppStrings.surveyUrl,
    this.title = 'Survey Tasks',
  });

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  int _loadingProgress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onProgress: (progress) {
            setState(() => _loadingProgress = progress);
          },
          onPageFinished: (_) {
            setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            setState(() {
              _loading = false;
              _error = 'Failed to load page. Check your internet connection.';
            });
          },
          onNavigationRequest: (request) {
            // Allow all navigation within the domain
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _error = null);
              _controller.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_outlined),
            tooltip: 'Open in browser',
            onPressed: () {
              // TODO: launch url in external browser
            },
          ),
        ],
        bottom: _loading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: AppColors.cardBg,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: _error != null
          ? _buildError()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading && _loadingProgress < 50)
                  Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      // Bottom navigation (back/forward)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navButton(Icons.arrow_back_ios_rounded, 'Back', () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            }),
            _navButton(Icons.home_rounded, 'Home', () {
              _controller.loadRequest(Uri.parse(widget.url));
            }),
            _navButton(Icons.arrow_forward_ios_rounded, 'Forward', () async {
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            }),
            _navButton(Icons.refresh_rounded, 'Reload', () {
              _controller.reload();
            }),
          ],
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌐', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Connection Failed',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Check your internet connection and try again.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() => _error = null);
                _controller.loadRequest(Uri.parse(widget.url));
              },
            ),
          ],
        ),
      ),
    );
  }
}
