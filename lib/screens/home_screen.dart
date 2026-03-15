// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../services/admob_service.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TMDBService _tmdb = TMDBService();
  final AdMobService _admob = AdMobService();

  List<Movie> _trending = [];
  List<Movie> _nowPlaying = [];
  List<Movie> _popularTV = [];
  List<Movie> _topRated = [];

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBannerAd();
    _admob.loadInterstitialAd();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _tmdb.getTrendingMovies(),
      _tmdb.getNowPlayingMovies(),
      _tmdb.getPopularTV(),
      _tmdb.getTopRatedMovies(),
    ]);
    setState(() {
      _trending = results[0];
      _nowPlaying = results[1];
      _popularTV = results[2];
      _topRated = results[3];
    });
  }

  void _loadBannerAd() {
    final ad = _admob.createBannerAd();
    if (ad == null) return;
    _bannerAd = ad..load().then((_) {
      if (mounted) setState(() => _bannerLoaded = true);
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _admob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildTabBar(),
                if (_trending.isNotEmpty) _buildHero(_trending.first),
                _buildSection('🔥 Tendances', _trending),
                _buildSection('🎬 En ce moment', _nowPlaying),
                _buildSection('📺 Séries populaires', _popularTV,
                    isMovie: false),
                _buildSection('⭐ Les mieux notés', _topRated),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          ),
          if (_bannerLoaded && _bannerAd != null)
            Container(
              color: Colors.black,
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      floating: true,
      title: const Text(
        'MOVIEMG',
        style: TextStyle(
          color: Color(0xFFE50914),
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildTabBar() {
    final tabs = ['Tout', 'Films', 'Séries', 'Tendances'];
    return SliverToBoxAdapter(
      child: Container(
        height: 45,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tabs.length,
          itemBuilder: (ctx, i) => GestureDetector(
            onTap: () => setState(() => _currentTab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _currentTab == i
                    ? const Color(0xFFE50914)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tabs[i],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHero(Movie movie) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => _openDetail(movie),
        child: Container(
          height: 220,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: CachedNetworkImageProvider(movie.backdropUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('TENDANCE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 6),
                Text(movie.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(' ${movie.voteAverage.toStringAsFixed(1)}',
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 10),
                    Text(movie.year,
                        style: const TextStyle(color: Colors.white70)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow,
                              color: Colors.white, size: 16),
                          Text(' Regarder',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSection(String title, List<Movie> movies,
      {bool isMovie = true}) {
    if (movies.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              itemBuilder: (ctx, i) => _buildMovieCard(movies[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _openDetail(movie),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: movie.posterUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (ctx, url) => Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFE50914), strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 10),
                Text(' ${movie.voteAverage.toStringAsFixed(1)}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Movie movie) {
    _admob.showInterstitialAd();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
    );
  }
}