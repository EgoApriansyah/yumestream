class GenreModel {
  final String title;
  final String genreId;
  final String href;

  const GenreModel({
    required this.title,
    required this.genreId,
    required this.href,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      title: json['title'] as String? ?? '',
      genreId: json['genreId'] as String? ?? '',
      href: json['href'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'genreId': genreId,
      'href': href,
    };
  }
}
