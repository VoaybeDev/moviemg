// lib/screens/player_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent('Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36') // ← Ajoute cette ligne
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
        ))
        ..loadRequest(Uri.parse(_vidsrcUrl));
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.movie.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: kIsWeb
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline,
                color: Colors.white54, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Lecture disponible sur Android uniquement',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914)),
              onPressed: () {},
              child: const Text('Ouvrir dans le navigateur'),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFE50914)),
            ),
        ],
      ),
    );
  }
}