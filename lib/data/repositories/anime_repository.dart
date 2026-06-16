import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';
import '../models/batch_model.dart';
import '../models/episode_detail_model.dart';
import '../models/genre_model.dart';
import '../models/home_model.dart';
import '../models/pagination_model.dart';
import '../models/schedule_model.dart';
import '../models/watch_history_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class AnimeRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  AnimeRepository({
    required ApiService apiService,
    required LocalStorageService localStorageService,
  })  : _apiService = apiService,
        _localStorageService = localStorageService;

  // ─── API Methods ──────────────────────────────────────
  Future<HomeModel> getHome() => _apiService.getHome();

  Future<({List<AnimeModel> animeList, PaginationModel? pagination})>
      getOngoingAnime({int page = 1}) =>
          _apiService.getOngoingAnime(page: page);

  Future<({List<AnimeModel> animeList, PaginationModel? pagination})>
      getCompleteAnime({int page = 1}) =>
          _apiService.getCompleteAnime(page: page);

  Future<List<GenreModel>> getGenres() => _apiService.getGenres();

  Future<({List<AnimeModel> animeList, PaginationModel? pagination})>
      getGenreAnime(String slug, {int page = 1}) =>
          _apiService.getGenreAnime(slug, page: page);

  Future<List<AnimeModel>> searchAnime(String keyword) =>
      _apiService.searchAnime(keyword);

  Future<List<ScheduleModel>> getSchedule() => _apiService.getSchedule();

  Future<AnimeDetailModel> getAnimeDetail(String slug) =>
      _apiService.getAnimeDetail(slug);

  Future<EpisodeDetailModel> getEpisodeDetail(String slug) =>
      _apiService.getEpisodeDetail(slug);

  Future<String> getServerUrl(String serverId) =>
      _apiService.getServerUrl(serverId);

  Future<BatchModel> getBatch(String slug) => _apiService.getBatch(slug);

  // ─── Local Storage Methods ────────────────────────────
  List<WatchlistItemModel> getWatchlist() =>
      _localStorageService.getWatchlist();

  bool isInWatchlist(String animeId) =>
      _localStorageService.isInWatchlist(animeId);

  Future<void> addToWatchlist(WatchlistItemModel item) =>
      _localStorageService.addToWatchlist(item);

  Future<void> removeFromWatchlist(String animeId) =>
      _localStorageService.removeFromWatchlist(animeId);

  Future<void> toggleWatchlist(WatchlistItemModel item) =>
      _localStorageService.toggleWatchlist(item);

  List<WatchHistoryModel> getWatchHistory() =>
      _localStorageService.getWatchHistory();

  Future<void> saveWatchHistory(WatchHistoryModel entry) =>
      _localStorageService.saveWatchHistory(entry);

  Future<void> removeWatchHistory(String animeId) =>
      _localStorageService.removeWatchHistory(animeId);

  WatchHistoryModel? getLatestWatchForAnime(String animeId) =>
      _localStorageService.getLatestWatchForAnime(animeId);
}
