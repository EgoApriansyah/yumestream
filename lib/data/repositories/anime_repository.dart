import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';
import '../models/batch_model.dart';
import '../models/episode_detail_model.dart';
import '../models/genre_model.dart';
import '../models/home_model.dart';
import '../models/pagination_model.dart';
import '../models/schedule_model.dart';
import '../models/watch_history_model.dart';
import '../models/dramabox_model.dart';
import '../models/komik_model.dart';
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

  // ─── DramaBox API methods ─────────────────────────────
  Future<List<DramaBoxBookModel>> getDramaBoxForyou({int page = 1}) =>
      _apiService.getDramaBoxForyou(page: page);

  Future<List<DramaBoxBookModel>> getDramaBoxLatest() =>
      _apiService.getDramaBoxLatest();

  Future<List<DramaBoxBookModel>> getDramaBoxTrending() =>
      _apiService.getDramaBoxTrending();

  Future<DramaBoxBookModel> getDramaBoxDetail(String bookId) =>
      _apiService.getDramaBoxDetail(bookId);

  Future<List<DramaBoxEpisodeModel>> getDramaBoxEpisodes(String bookId) =>
      _apiService.getDramaBoxEpisodes(bookId);

  Future<DramaBoxDecryptedModel> decryptDramaBoxUrl(String url) =>
      _apiService.decryptDramaBoxUrl(url);

  // ─── Comic API methods ────────────────────────────────
  Future<List<ComicModel>> getComicLatest({int page = 1}) =>
      _apiService.getComicLatest(page: page);

  Future<List<ComicModel>> getComicPopuler({int page = 1}) =>
      _apiService.getComicPopuler(page: page);

  Future<List<ComicModel>> getComicTrending() => _apiService.getComicTrending();

  Future<List<ComicModel>> getComicPustaka({int page = 1}) =>
      _apiService.getComicPustaka(page: page);

  Future<ComicDetailModel> getComicDetail(String slug) =>
      _apiService.getComicDetail(slug);

  Future<ComicChapterImagesModel> getComicChapterImages(String slug) =>
      _apiService.getComicChapterImages(slug);

  Future<ComicChapterNavigationModel> getComicChapterNavigation(String slug) =>
      _apiService.getComicChapterNavigation(slug);

  Future<List<ComicModel>> searchComic(String query, {int page = 1}) =>
      _apiService.searchComic(query, page: page);

  Future<List<ComicModel>> getComicByType(String type, {int page = 1}) =>
      _apiService.getComicByType(type, page: page);

  Future<List<ComicModel>> getComicByGenre(String genre, {int page = 1}) =>
      _apiService.getComicByGenre(genre, page: page);

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
