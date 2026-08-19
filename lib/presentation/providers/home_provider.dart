import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/repositories/anime_repository.dart';
import '../../data/models/home_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/watch_history_model.dart';
import '../../data/models/dramabox_model.dart';
import '../../data/models/komik_model.dart';
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
final scheduleProvider = FutureProvider<List<UnifiedScheduleSection>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  
  final results = await Future.wait([
    repo.getSchedule(),
    repo.getDramaBoxLatest().catchError((e) {
      debugPrint("Gagal memuat DramaBox Latest: $e");
      return <DramaBoxBookModel>[];
    }),
    repo.getComicLatest().catchError((e) {
      debugPrint("Gagal memuat Comic Latest: $e");
      return <ComicModel>[];
    }),
  ]);

  final animeSchedule = results[0] as List<ScheduleModel>;
  final dramaboxLatest = results[1] as List<DramaBoxBookModel>;
  final comicLatest = results[2] as List<ComicModel>;

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

  // 2. Group DramaBox
  for (final book in dramaboxLatest) {
    if (book.shelfTime != null && book.shelfTime!.isNotEmpty) {
      try {
        final dateStr = book.shelfTime!.replaceAll(' ', 'T');
        final dateTime = DateTime.parse(dateStr);
        final day = dateTime.dayNameIndonesian;
        if (groupedItems.containsKey(day)) {
          groupedItems[day]!.add(UnifiedScheduleItem(
            id: book.bookId,
            title: book.bookName,
            imageUrl: book.coverWap,
            subtitle: '${book.chapterCount} Episode',
            typeLabel: 'Drama Box',
            type: UnifiedScheduleType.dramabox,
          ));
        }
      } catch (e) {
        debugPrint("Error parsing shelfTime for book ${book.bookName}: $e");
      }
    }
  }

  // 3. Group Comics
  for (final comic in comicLatest) {
    final timeStr = comic.updatedAt ?? comic.latestChapterTime;
    if (timeStr != null && timeStr.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(timeStr);
        final day = dateTime.dayNameIndonesian;
        if (groupedItems.containsKey(day)) {
          groupedItems[day]!.add(UnifiedScheduleItem(
            id: comic.mangaId,
            title: comic.title,
            imageUrl: comic.coverImageUrl,
            subtitle: comic.latestChapterNumber != null && comic.latestChapterNumber!.isNotEmpty
                ? 'Chapter ${comic.latestChapterNumber}'
                : 'Rating: ${comic.userRate}',
            typeLabel: 'Komik',
            type: UnifiedScheduleType.komik,
          ));
        }
      } catch (e) {
        debugPrint("Error parsing update time for comic ${comic.title}: $e");
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
