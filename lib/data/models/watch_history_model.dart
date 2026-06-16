import 'package:hive/hive.dart';

part 'watch_history_model.g.dart';

@HiveType(typeId: 0)
class WatchHistoryModel extends HiveObject {
  @HiveField(0)
  final String animeId;

  @HiveField(1)
  final String animeTitle;

  @HiveField(2)
  final String poster;

  @HiveField(3)
  final String episodeId;

  @HiveField(4)
  final int episodeNumber;

  @HiveField(5)
  final double progress; // 0.0 - 1.0

  @HiveField(6)
  final DateTime timestamp;

  WatchHistoryModel({
    required this.animeId,
    required this.animeTitle,
    required this.poster,
    required this.episodeId,
    required this.episodeNumber,
    this.progress = 0.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

@HiveType(typeId: 1)
class WatchlistItemModel extends HiveObject {
  @HiveField(0)
  final String animeId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String poster;

  @HiveField(3)
  final String? score;

  @HiveField(4)
  final String? status;

  @HiveField(5)
  final DateTime addedAt;

  WatchlistItemModel({
    required this.animeId,
    required this.title,
    required this.poster,
    this.score,
    this.status,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}
