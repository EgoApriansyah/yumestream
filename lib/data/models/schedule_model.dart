import 'anime_model.dart';

class ScheduleModel {
  final String day;
  final List<AnimeModel> animeList;

  const ScheduleModel({
    required this.day,
    required this.animeList,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      day: json['day'] as String? ?? '',
      animeList: json['anime_list'] != null
          ? (json['anime_list'] as List)
              .map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

enum UnifiedScheduleType { anime, komik }

class UnifiedScheduleItem {
  final String id;
  final String title;
  final String imageUrl;
  final String subtitle;
  final String typeLabel;
  final UnifiedScheduleType type;

  const UnifiedScheduleItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.typeLabel,
    required this.type,
  });
}

class UnifiedScheduleSection {
  final String day;
  final List<UnifiedScheduleItem> items;

  const UnifiedScheduleSection({
    required this.day,
    required this.items,
  });
}
