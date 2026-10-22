import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/repositories/anime_repository.dart';
import '../../data/models/home_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/watch_history_model.dart';
import '../../data/models/komik_model.dart';
import '../../core/utils/extensions.dart';
import 'komik_provider.dart';

// ─── Core Service Providers ─────────────────────────────
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
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

// ─── Favorite Updates Checker Provider ──────────────────
final favoriteUpdatesCheckerProvider = FutureProvider<void>((ref) async {
  final animeFavorites = ref.watch(watchlistProvider);
  final comicFavorites = ref.watch(comicFavoritesProvider);
  final apiService = ref.read(apiServiceProvider);
  final notifService = ref.read(notificationServiceProvider);
  await notifService.checkForUpdates(
    animeFavorites: animeFavorites,
    comicFavorites: comicFavorites,
    apiService: apiService,
  );
});

DateTime? _parseRelativeOrAbsoluteDate(String? str) {
  if (str == null || str.trim().isEmpty) return null;
  final s = str.trim().toLowerCase();
  final now = DateTime.now();

  if (s.contains('menit') || s.contains('jam') || s.contains('detik') || s.contains('baru saja')) {
    return now;
  }
  final dayMatch = RegExp(r'(\d+)\s*hari\s*lalu').firstMatch(s);
  if (dayMatch != null) {
    final days = int.tryParse(dayMatch.group(1)!) ?? 0;
    return now.subtract(Duration(days: days));
  }
  final weekMatch = RegExp(r'(\d+)\s*minggu\s*lalu').firstMatch(s);
  if (weekMatch != null) {
    final weeks = int.tryParse(weekMatch.group(1)!) ?? 0;
    return now.subtract(Duration(days: weeks * 7));
  }
  return DateTime.tryParse(str);
}

// ─── Schedule Provider ──────────────────────────────────
final scheduleProvider = FutureProvider<List<UnifiedScheduleSection>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  
  final results = await Future.wait([
    repo.getSchedule().catchError((e) {
      debugPrint("Gagal memuat Anime Schedule: $e");
      return <ScheduleModel>[];
    }),
    repo.getComicLatest(page: 1).catchError((e) {
      debugPrint("Gagal memuat Comic Latest p1: $e");
      return <ComicModel>[];
    }),
    repo.getComicLatest(page: 2).catchError((e) {
      debugPrint("Gagal memuat Comic Latest p2: $e");
      return <ComicModel>[];
    }),
  ]);

  final animeSchedule = results[0] as List<ScheduleModel>;
  final comicLatestP1 = results[1] as List<ComicModel>;
  final comicLatestP2 = results[2] as List<ComicModel>;
  final comicLatest = [...comicLatestP1, ...comicLatestP2];

  final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  final Map<String, List<UnifiedScheduleItem>> groupedItems = {
    for (var day in days) day: [],
  };

  // 1. Group Anime
  for (final schedule in animeSchedule) {
    final day = schedule.day;
    if (groupedItems.containsKey(day)) {
      for (final anime in schedule.animeList) {
        groupedItems[day]!.add(UnifiedScheduleItem(
          id: anime.animeId,
          title: anime.title,
          imageUrl: anime.poster,
          subtitle: anime.episodes != null && anime.episodes! > 0
              ? '${anime.episodes} Episode'
              : 'Status: ${anime.status ?? "Ongoing"}',
          typeLabel: 'Anime',
          type: UnifiedScheduleType.anime,
        ));
      }
    }
  }

  // 2. Group Comics by Release / Update Day
  final Set<String> addedComicSlugs = {};
  for (final comic in comicLatest) {
    if (addedComicSlugs.contains(comic.mangaId)) continue;
    addedComicSlugs.add(comic.mangaId);

    final timeStr = comic.latestChapterTime ?? comic.updatedAt;
    final dateTime = _parseRelativeOrAbsoluteDate(timeStr);
    if (dateTime != null) {
      final day = dateTime.dayNameIndonesian;
      if (groupedItems.containsKey(day)) {
        groupedItems[day]!.add(UnifiedScheduleItem(
          id: comic.mangaId,
          title: comic.title,
          imageUrl: comic.coverImageUrl,
          subtitle: comic.latestChapterNumber != null && comic.latestChapterNumber!.isNotEmpty
              ? comic.latestChapterNumber!
              : (comic.type ?? 'Komik'),
          typeLabel: comic.type ?? 'Komik',
          type: UnifiedScheduleType.komik,
        ));
      }
    }
  }

  return days.map((day) {
    return UnifiedScheduleSection(
      day: day,
      items: groupedItems[day]!,
    );
  }).toList();
});

final selectedDayProvider = StateProvider<String>((ref) {
  return DateTime.now().dayNameIndonesian;
});

// ─── Today Schedule (derived) ───────────────────────────
final todayScheduleProvider = FutureProvider<List<UnifiedScheduleItem>>((ref) async {
  final scheduleAsync = await ref.watch(scheduleProvider.future);
  final today = DateTime.now().dayNameIndonesian;
  final todaySchedule = scheduleAsync.firstWhere(
    (s) => s.day == today,
    orElse: () => UnifiedScheduleSection(day: today, items: const []),
  );
  return todaySchedule.items;
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
