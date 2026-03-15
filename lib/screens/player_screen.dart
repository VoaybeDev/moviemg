// lib/screens/player_screen.dart

import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:html' as html;
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
  late WebViewController _controller;
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
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) => setState(() => _loading = false),
          ),
        )
        ..loadRequest(Uri.parse(_vidsrcUrl));
    } else {
      // Pour le web : enregistrer l'iframe
      final String viewId = 'vidsrc-${widget.movie.id}';
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
            (int id) {
          final iframe = html.IFrameElement()
            ..src = _vidsrcUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true
            ..setAttribute('allow', 'autoplay; fullscreen');
          return iframe;
        },
      );
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
      body: _loading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE50914)),
            SizedBox(height: 16),
            Text('Chargement...',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      )
          : kIsWeb
          ? HtmlElementView(
        viewType: 'vidsrc-${widget.movie.id}',
      )
          : Stack(
        children: [
          WebViewWidget(controller: _controller),
        ],
      ),
    );
  }
}