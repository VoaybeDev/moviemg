// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'player_screen.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TMDBService _tmdb = TMDBService();
  Map<String, dynamic> _details = {};
  List<Movie> _similar = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details = await _tmdb.getMovieDetails(
      widget.movie.id,
      widget.movie.isMovie,
    );
    final similar = await _tmdb.getTrendingMovies();
    setState(() {
      _details = details;
      _similar = similar.take(10).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(movie),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(movie),
                  const SizedBox(height: 16),
                  _buildPlayButton(movie),
                  const SizedBox(height: 20),
                  _buildOverview(movie),
                  const SizedBox(height: 20),
                  _buildInfo(movie),
                  const SizedBox(height: 24),
                  if (_similar.isNotEmpty) _buildSimilar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(Movie movie) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.backdropUrl,
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF0A0A0A)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(Movie movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: movie.posterUrl,
            width: 100,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(
                    ' ${movie.voteAverage.toStringAsFixed(1)}/10',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(movie.year,
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  movie.isMovie ? 'FILM' : 'SÉRIE',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(Movie movie) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE50914),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text(
          'REGARDER MAINTENANT',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
        ),
      ),
    );
  }

  Widget _buildOverview(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Synopsis',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          movie.overview ?? 'Aucun synopsis disponible.',
          style: const TextStyle(
              color: Colors.white70, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildInfo(Movie movie) {
    final genresList = _details['genres'];
    final genres = genresList is List
        ? genresList.map((g) => g['name'] as String).join(', ')
        : '';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (genres.isNotEmpty) _chip('🎭 $genres'),
        if (movie.year.isNotEmpty) _chip('📅 ${movie.year}'),
        _chip(movie.isMovie ? '🎬 Film' : '📺 Série'),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _buildSimilar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vous aimerez aussi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _similar.length,
            itemBuilder: (ctx, i) {
              final m = _similar[i];
              return GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(movie: m)),
                ),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: m.posterUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}