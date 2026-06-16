import 'genre_model.dart';

/// Unified anime model used across home, ongoing, completed, and search results.
/// Fields are nullable to accommodate different API response shapes.
class AnimeModel {
  final String title;
  final String poster;
  final int? episodes;
  final String? releaseDay;
  final String? latestReleaseDate;
  final String animeId;
  final String href;

  // Completed anime fields
  final String? score;
  final String? lastReleaseDate;

  // Search result fields
  final String? status;
  final List<GenreModel>? genreList;

  const AnimeModel({
    required this.title,
    required this.poster,
    this.episodes,
    this.releaseDay,
    this.latestReleaseDate,
    required this.animeId,
    required this.href,
    this.score,
    this.lastReleaseDate,
    this.status,
    this.genreList,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      title: json['title'] as String? ?? '',
      poster: json['poster'] as String? ?? '',
      episodes: json['episodes'] as int?,
      releaseDay: json['releaseDay'] as String?,
      latestReleaseDate: json['latestReleaseDate'] as String?,
      animeId: json['animeId'] as String? ?? json['slug'] as String? ?? '',
      href: json['href'] as String? ?? json['url'] as String? ?? '',
      score: json['score'] as String?,
      lastReleaseDate: json['lastReleaseDate'] as String?,
      status: json['status'] as String?,
      genreList: json['genreList'] != null
          ? (json['genreList'] as List)
              .map((g) => GenreModel.fromJson(g as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'poster': poster,
      'episodes': episodes,
      'releaseDay': releaseDay,
      'latestReleaseDate': latestReleaseDate,
      'animeId': animeId,
      'href': href,
      'score': score,
      'lastReleaseDate': lastReleaseDate,
      'status': status,
    };
  }
}
