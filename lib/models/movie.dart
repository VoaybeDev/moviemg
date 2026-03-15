// lib/models/movie.dart

class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final List<int> genreIds;
  final bool isMovie;

  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
    this.isMovie = true,
  });

  String get posterUrl =>
      posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : 'https://via.placeholder.com/500x750?text=No+Image';

  String get backdropUrl =>
      backdropPath != null
          ? 'https://image.tmdb.org/t/p/original$backdropPath'
          : posterUrl;

  String get year =>
      releaseDate != null && releaseDate!.length >= 4
          ? releaseDate!.substring(0, 4)
          : '';

  String get vidsrcUrl =>
      isMovie
          ? 'https://vidsrc.to/embed/movie/$id'
          : 'https://vidsrc.to/embed/tv/$id';

  factory Movie.fromJson(Map<String, dynamic> json, {bool isMovie = true}) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Sans titre',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? json['first_air_date'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      isMovie: isMovie,
    );
  }
}