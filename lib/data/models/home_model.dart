import 'anime_model.dart';

class HomeModel {
  final HomeSection ongoing;
  final HomeSection completed;

  const HomeModel({
    required this.ongoing,
    required this.completed,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      ongoing: HomeSection.fromJson(json['ongoing'] as Map<String, dynamic>),
      completed:
          HomeSection.fromJson(json['completed'] as Map<String, dynamic>),
    );
  }
}

class HomeSection {
  final String href;
  final List<AnimeModel> animeList;

  const HomeSection({
    required this.href,
    required this.animeList,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      href: json['href'] as String? ?? '',
      animeList: json['animeList'] != null
          ? (json['animeList'] as List)
              .map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
