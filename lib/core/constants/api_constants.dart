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

  // Comic Endpoints
  static const String comicHomepage = '/comic/homepage';
  static const String comicTerbaru = '/comic/terbaru';
  static const String comicPopuler = '/comic/populer';
  static const String comicTrending = '/comic/trending';
  static const String comicGenres = '/comic/genres';
  static String comicDetail(String slug) => '/comic/comic/$slug';
  static String comicChapter(String slug) => '/comic/chapter/$slug';
  static String comicChapterNavigation(String slug) => '/comic/chapter/$slug/navigation';
  static String comicSearch(String query) => '/comic/search?q=${Uri.encodeComponent(query)}';
  static String comicType(String type) => '/comic/type/$type';
  static String comicGenre(String genre) => '/comic/genre/$genre';
  static String comicPustaka(int page) => '/comic/pustaka/$page';

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
