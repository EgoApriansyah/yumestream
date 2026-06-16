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
