class EpisodeModel {
  final String title;
  final int eps;
  final String date;
  final String episodeId;
  final String href;

  const EpisodeModel({
    required this.title,
    required this.eps,
    required this.date,
    required this.episodeId,
    required this.href,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      title: json['title'] as String? ?? '',
      eps: json['eps'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      episodeId: json['episodeId'] as String? ?? '',
      href: json['href'] as String? ?? '',
    );
  }
}
