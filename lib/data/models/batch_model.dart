import 'server_model.dart';
import 'genre_model.dart';

class BatchModel {
  final String title;
  final String animeId;
  final String poster;
  final String? japanese;
  final String? type;
  final String? score;
  final int? episodes;
  final String? duration;
  final String? studios;
  final String? aired;
  final List<GenreModel> genreList;
  final BatchDownloadData? downloadUrl;

  const BatchModel({
    required this.title,
    required this.animeId,
    required this.poster,
    this.japanese,
    this.type,
    this.score,
    this.episodes,
    this.duration,
    this.studios,
    this.aired,
    required this.genreList,
    this.downloadUrl,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      title: json['title'] as String? ?? '',
      animeId: json['animeId'] as String? ?? '',
      poster: json['poster'] as String? ?? '',
      japanese: json['japanese'] as String?,
      type: json['type'] as String?,
      score: json['score'] as String?,
      episodes: json['episodes'] as int?,
      duration: json['duration'] as String?,
      studios: json['studios'] as String?,
      aired: json['aired'] as String?,
      genreList: json['genreList'] != null
          ? (json['genreList'] as List)
              .map((g) => GenreModel.fromJson(g as Map<String, dynamic>))
              .toList()
          : [],
      downloadUrl: json['downloadUrl'] != null
          ? BatchDownloadData.fromJson(
              json['downloadUrl'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BatchDownloadData {
  final List<BatchFormatModel> formats;

  const BatchDownloadData({required this.formats});

  factory BatchDownloadData.fromJson(Map<String, dynamic> json) {
    return BatchDownloadData(
      formats: json['formats'] != null
          ? (json['formats'] as List)
              .map(
                  (f) => BatchFormatModel.fromJson(f as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class BatchFormatModel {
  final String title;
  final List<DownloadQualityModel> qualities;

  const BatchFormatModel({
    required this.title,
    required this.qualities,
  });

  factory BatchFormatModel.fromJson(Map<String, dynamic> json) {
    return BatchFormatModel(
      title: json['title'] as String? ?? '',
      qualities: json['qualities'] != null
          ? (json['qualities'] as List)
              .map((q) =>
                  DownloadQualityModel.fromJson(q as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
