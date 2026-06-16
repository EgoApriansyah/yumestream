class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://www.sankavollerei.web.id';

  // Endpoints
  static const String home = '/anime/home';
  static const String ongoingAnime = '/anime/ongoing-anime';
  static const String completeAnime = '/anime/complete-anime';
  static const String genre = '/anime/genre';
  static const String schedule = '/anime/schedule';
  static const String unlimited = '/anime/unlimited';

  // Parameterized endpoints
  static String genreBySlug(String slug) => '/anime/genre/$slug';
  static String search(String keyword) => '/anime/search/$keyword';
  static String animeDetail(String slug) => '/anime/anime/$slug';
  static String episodeDetail(String slug) => '/anime/episode/$slug';
  static String server(String serverId) => '/anime/server/$serverId';
  static String batch(String slug) => '/anime/batch/$slug';

  // Timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
