// lib/screens/player_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/movie.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  final int? season;
  final int? episode;

  const PlayerScreen({
    super.key,
    required this.movie,
    this.season,
    this.episode,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  WebViewController? _controller;
  bool _loading = true;

  String get _vidsrcUrl {
    final movie = widget.movie;
    if (movie.isMovie) {
      return 'https://vidsrc.to/embed/movie/${movie.id}';
    } else {
      final s = widget.season ?? 1;
      final e = widget.episode ?? 1;
      return 'https://vidsrc.to/embed/tv/${movie.id}/$s/$e';
    }
  }

  // JavaScript pour bloquer les pubs et redirections
  static const String _adBlockScript = '''
    // Bloquer les popups
    window.open = function() { return null; };
    window.alert = function() {};
    window.confirm = function() { return false; };
    
    // Bloquer les redirections automatiques
    var _pushState = history.pushState;
    history.pushState = function() {
      if (arguments[2] && !arguments[2].toString().includes('vidsrc')) return;
      _pushState.apply(history, arguments);
    };
    
    // Supprimer les overlays publicitaires
    var observer = new MutationObserver(function(mutations) {
      var selectors = [
        'iframe[src*="ads"]',
        'iframe[src*="doubleclick"]',
        'iframe[src*="googlesyndication"]',
        'div[id*="ad"]',
        'div[class*="ad-"]',
        'div[class*="popup"]',
        'div[class*="overlay"]',
        'a[target="_blank"]',
      ];
      selectors.forEach(function(sel) {
        document.querySelectorAll(sel).forEach(function(el) {
          el.remove();
        });
      });
    });
    observer.observe(document.body || document.documentElement, {
      childList: true,
      subtree: true
    });
    
    // Bloquer les clics sur les zones pub
    document.addEventListener('click', function(e) {
      var el = e.target;
      while (el) {
        var href = el.href || '';
        var src = el.src || '';
        if ((href && !href.includes('vidsrc')) || 
            (src && !src.includes('vidsrc') && !src.includes('filevero'))) {
          e.preventDefault();
          e.stopPropagation();
          return false;
        }
        el = el.parentElement;
      }
    }, true);
  ''';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _loading = false);
            // Injecter le script anti-pub après chargement
            _controller?.runJavaScript(_adBlockScript);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            // Autoriser seulement les URLs de streaming
            final allowed = [
              'vidsrc.to',
              'vidsrc.me',
              'filevero.com',
              'vidplay.online',
              'about:blank',
              'vidsrc.xyz',
            ];
            for (final domain in allowed) {
              if (url.contains(domain)) {
                return NavigationDecision.navigate;
              }
            }
            debugPrint('Bloqué: $url');
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(_vidsrcUrl));
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!),
          if (_loading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE50914)),
                  SizedBox(height: 16),
                  Text('Chargement...',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          // Bouton retour
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}