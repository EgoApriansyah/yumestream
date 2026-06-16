import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/repositories/anime_repository.dart';
import '../../data/models/home_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/watch_history_model.dart';
import '../../core/utils/extensions.dart';

// ─── Core Service Providers ─────────────────────────────
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  return AnimeRepository(
    apiService: ref.read(apiServiceProvider),
    localStorageService: ref.read(localStorageServiceProvider),
  );
});

// ─── Home Provider ──────────────────────────────────────
final homeDataProvider = FutureProvider<HomeModel>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getHome();
});

// ─── Schedule Provider ──────────────────────────────────
final scheduleProvider = FutureProvider<List<ScheduleModel>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getSchedule();
});

final selectedDayProvider = StateProvider<String>((ref) {
  return DateTime.now().dayNameIndonesian;
});

// ─── Today Schedule (derived) ───────────────────────────
final todayScheduleProvider = FutureProvider<List<dynamic>>((ref) async {
  final scheduleAsync = await ref.watch(scheduleProvider.future);
  final today = DateTime.now().dayNameIndonesian;
  final todaySchedule = scheduleAsync.firstWhere(
    (s) => s.day == today,
    orElse: () => ScheduleModel(day: today, animeList: []),
  );
  return todaySchedule.animeList;
});

// ─── Watch History Provider ─────────────────────────────
final watchHistoryProvider =
    StateNotifierProvider<WatchHistoryNotifier, List<WatchHistoryModel>>(
        (ref) {
  final repo = ref.read(animeRepositoryProvider);
  return WatchHistoryNotifier(repo);
});

class WatchHistoryNotifier extends StateNotifier<List<WatchHistoryModel>> {
  final AnimeRepository _repo;

  WatchHistoryNotifier(this._repo) : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    state = _repo.getWatchHistory();
  }

  Future<void> saveHistory(WatchHistoryModel entry) async {
    await _repo.saveWatchHistory(entry);
    _loadHistory();
  }

  Future<void> removeHistory(String animeId) async {
    await _repo.removeWatchHistory(animeId);
    _loadHistory();
  }

  void refresh() => _loadHistory();
}

// ─── Watchlist Provider ─────────────────────────────────
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<WatchlistItemModel>>((ref) {
  final repo = ref.read(animeRepositoryProvider);
  return WatchlistNotifier(repo);
});

class WatchlistNotifier extends StateNotifier<List<WatchlistItemModel>> {
  final AnimeRepository _repo;

  WatchlistNotifier(this._repo) : super([]) {
    _loadWatchlist();
  }

  void _loadWatchlist() {
    state = _repo.getWatchlist();
  }

  bool isInWatchlist(String animeId) => _repo.isInWatchlist(animeId);

  Future<void> toggle(WatchlistItemModel item) async {
    await _repo.toggleWatchlist(item);
    _loadWatchlist();
  }

  Future<void> remove(String animeId) async {
    await _repo.removeFromWatchlist(animeId);
    _loadWatchlist();
  }

  void refresh() => _loadWatchlist();
}
