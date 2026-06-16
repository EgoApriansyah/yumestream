import 'genre_model.dart';
import 'episode_model.dart';
import 'anime_model.dart';

class AnimeDetailModel {
  final String title;
  final String poster;
  final String japanese;
  final String? score;
  final String? producers;
  final String? type;
  final String? status;
  final int? episodes;
  final String? duration;
  final String? aired;
  final String? studios;
  final String? batch; // batch slug, null if no batch available
  final SynopsisModel? synopsis;
  final List<GenreModel> genreList;
  final List<EpisodeModel> episodeList;
  final List<AnimeModel> recommendedAnimeList;

  const AnimeDetailModel({
    required this.title,
    required this.poster,
    required this.japanese,
    this.score,
    this.producers,
    this.type,
    this.status,
    this.episodes,
    this.duration,
    this.aired,
    this.studios,
    this.batch,
    this.synopsis,
    required this.genreList,
    required this.episodeList,
    required this.recommendedAnimeList,
  });

  factory AnimeDetailModel.fromJson(Map<String, dynamic> json) {
    return AnimeDetailModel(
      title: json['title'] as String? ?? '',
      poster: json['poster'] as String? ?? '',
      japanese: json['japanese'] as String? ?? '',
      score: json['score']?.toString(),
      producers: json['producers']?.toString(),
      type: json['type']?.toString(),
      status: json['status']?.toString(),
      episodes: json['episodes'] is int 
          ? json['episodes'] as int 
          : int.tryParse(json['episodes']?.toString() ?? ''),
      duration: json['duration']?.toString(),
      aired: json['aired']?.toString(),
      studios: json['studios']?.toString(),
      batch: json['batch'] is Map 
          ? ((json['batch'] as Map)['href']?.toString() ?? 'available')
          : json['batch']?.toString(),
      synopsis: json['synopsis'] != null
          ? SynopsisModel.fromJson(json['synopsis'] as Map<String, dynamic>)
          : null,
      genreList: json['genreList'] != null
          ? (json['genreList'] as List)
              .map((g) => GenreModel.fromJson(g as Map<String, dynamic>))
              .toList()
          : [],
      episodeList: json['episodeList'] != null
          ? (json['episodeList'] as List)
              .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      recommendedAnimeList: json['recommendedAnimeList'] != null
          ? (json['recommendedAnimeList'] as List)
              .map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class SynopsisModel {
  final List<String> paragraphs;

  const SynopsisModel({required this.paragraphs});

  factory SynopsisModel.fromJson(Map<String, dynamic> json) {
    return SynopsisModel(
      paragraphs: json['paragraphs'] != null
          ? (json['paragraphs'] as List).map((p) => p as String).toList()
          : [],
    );
  }

  String get fullText => paragraphs.join('\n\n');
}
