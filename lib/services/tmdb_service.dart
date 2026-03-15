// lib/services/tmdb_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TMDBService {
  // ⚠️ Remplace par ta clé API TMDB
  static const String _apiKey = '6a65d799c5fe52b6af80a174777045af';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _language = 'fr-FR';

  Future<List<Movie>> getTrendingMovies() async =>
      _fetchMovies('/trending/movie/week');

  Future<List<Movie>> getPopularMovies() async =>
      _fetchMovies('/movie/popular');

  Future<List<Movie>> getNowPlayingMovies() async =>
      _fetchMovies('/movie/now_playing');

  Future<List<Movie>> getUpcomingMovies() async =>
      _fetchMovies('/movie/upcoming');

  Future<List<Movie>> getTopRatedMovies() async =>
      _fetchMovies('/movie/top_rated');

  Future<List<Movie>> getTrendingTV() async =>
      _fetchMovies('/trending/tv/week', isMovie: false);

  Future<List<Movie>> getPopularTV() async =>
      _fetchMovies('/tv/popular', isMovie: false);

  Future<List<Movie>> getOnAirTV() async =>
      _fetchMovies('/tv/on_the_air', isMovie: false);

  Future<List<Movie>> searchMovies(String query) async {
    final movies = await _fetchMovies('/search/movie',
        extraParams: {'query': query});
    final shows = await _fetchMovies('/search/tv',
        extraParams: {'query': query}, isMovie: false);
    return [...movies, ...shows];
  }

  Future<Map<String, dynamic>> getMovieDetails(int id, bool isMovie) async {
    final endpoint = isMovie ? '/movie/$id' : '/tv/$id';
    final url = Uri.parse(
      '$_baseUrl$endpoint?api_key=$_apiKey&language=$_language&append_to_response=videos,credits',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<Movie>> _fetchMovies(
      String endpoint, {
        bool isMovie = true,
        Map<String, String>? extraParams,
      }) async {
    final params = {
      'api_key': _apiKey,
      'language': _language,
      'page': '1',
      ...?extraParams,
    };

    final url = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: params,
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>, isMovie: isMovie))
            .where((m) => m.posterPath != null)
            .toList();
      }
    } catch (e) {
      debugPrint('TMDB Error: $e');
    }
    return [];
  }
}