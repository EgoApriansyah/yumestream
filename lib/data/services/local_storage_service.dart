import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/watch_history_model.dart';
import '../models/komik_model.dart';

class LocalStorageService {
  static const String _watchlistBoxName = 'watchlist';
  static const String _watchHistoryBoxName = 'watch_history';
  static const String _comicFavoritesBoxName = 'comic_favorites';
  static const String _comicReadChaptersBoxName = 'comic_read_chapters';

  late Box<WatchlistItemModel> _watchlistBox;
  late Box<WatchHistoryModel> _watchHistoryBox;
  late Box _comicFavoritesBox;
  late Box _comicReadChaptersBox;

  Future<void> init() async {
    _watchlistBox = await Hive.openBox<WatchlistItemModel>(_watchlistBoxName);
    _watchHistoryBox =
        await Hive.openBox<WatchHistoryModel>(_watchHistoryBoxName);
    _comicFavoritesBox = await Hive.openBox(_comicFavoritesBoxName);
    _comicReadChaptersBox = await Hive.openBox(_comicReadChaptersBoxName);
  }

  // ─── ANIME WATCHLIST / FAVORITES ─────────────────────
  List<WatchlistItemModel> getWatchlist() {
    return _watchlistBox.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  bool isInWatchlist(String animeId) {
    return _watchlistBox.containsKey(animeId);
  }

  Future<void> addToWatchlist(WatchlistItemModel item) async {
    await _watchlistBox.put(item.animeId, item);
    debugPrint('Added to anime watchlist: ${item.title}');
  }

  Future<void> removeFromWatchlist(String animeId) async {
    await _watchlistBox.delete(animeId);
    debugPrint('Removed from anime watchlist: $animeId');
  }

  Future<void> toggleWatchlist(WatchlistItemModel item) async {
    if (isInWatchlist(item.animeId)) {
      await removeFromWatchlist(item.animeId);
    } else {
      await addToWatchlist(item);
    }
  }

  // ─── COMIC FAVORITES ──────────────────────────────────
  List<ComicModel> getComicFavorites() {
    final list = <Map<String, dynamic>>[];
    for (var key in _comicFavoritesBox.keys) {
      final raw = _comicFavoritesBox.get(key);
      if (raw != null) {
        if (raw is Map) {
          list.add(Map<String, dynamic>.from(raw));
        } else if (raw is String) {
          try {
            list.add(Map<String, dynamic>.from(jsonDecode(raw) as Map));
          } catch (_) {}
        }
      }
    }
    // Sort by addedAt descending
    list.sort((a, b) {
      final tA = a['addedAt']?.toString() ?? '';
      final tB = b['addedAt']?.toString() ?? '';
      return tB.compareTo(tA);
    });

    return list.map((item) => ComicModel.fromJson(item)).toList();
  }

  bool isComicFavorite(String mangaId) {
    return _comicFavoritesBox.containsKey(mangaId);
  }

  Future<void> saveComicFavorite(ComicModel comic) async {
    final map = {
      'slug': comic.mangaId,
      'title': comic.title,
      'image': comic.coverImageUrl,
      'type': comic.type,
      'latest_chapter_number': comic.latestChapterNumber,
      'rating': comic.userRate,
      'addedAt': DateTime.now().toIso8601String(),
    };
    await _comicFavoritesBox.put(comic.mangaId, map);
    debugPrint('Added comic to favorites: ${comic.title}');
  }

  Future<void> removeComicFavorite(String mangaId) async {
    await _comicFavoritesBox.delete(mangaId);
    debugPrint('Removed comic from favorites: $mangaId');
  }

  Future<void> toggleComicFavorite(ComicModel comic) async {
    if (isComicFavorite(comic.mangaId)) {
      await removeComicFavorite(comic.mangaId);
    } else {
      await saveComicFavorite(comic);
    }
  }

  // ─── COMIC READ CHAPTERS TRACKING ─────────────────────
  bool isChapterRead({required String comicSlug, required String chapterSlug}) {
    final compositeKey = '${comicSlug}_$chapterSlug';
    return _comicReadChaptersBox.get(compositeKey) == true ||
        _comicReadChaptersBox.get(chapterSlug) == true;
  }

  Future<void> markChapterRead({
    required String comicSlug,
    required String chapterSlug,
  }) async {
    final compositeKey = '${comicSlug}_$chapterSlug';
    await _comicReadChaptersBox.put(compositeKey, true);
    await _comicReadChaptersBox.put(chapterSlug, true);
    debugPrint('Marked chapter as read: $comicSlug -> $chapterSlug');
  }

  Set<String> getAllReadChapterSlugs() {
    final set = <String>{};
    for (var key in _comicReadChaptersBox.keys) {
      if (_comicReadChaptersBox.get(key) == true) {
        set.add(key.toString());
      }
    }
    return set;
  }

  // ─── WATCH HISTORY (Continue Watching) ────────────────
  List<WatchHistoryModel> getWatchHistory() {
    final allHistory = _watchHistoryBox.values.toList();
    // Group by animeId, keep latest per anime
    final Map<String, WatchHistoryModel> latestPerAnime = {};
    for (final entry in allHistory) {
      final existing = latestPerAnime[entry.animeId];
      if (existing == null ||
          entry.timestamp.isAfter(existing.timestamp)) {
        latestPerAnime[entry.animeId] = entry;
      }
    }
    final result = latestPerAnime.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  }

  Future<void> saveWatchHistory(WatchHistoryModel entry) async {
    final key = '${entry.animeId}_${entry.episodeId}';
    await _watchHistoryBox.put(key, entry);
    debugPrint(
        'Saved watch history: ${entry.animeTitle} ep${entry.episodeNumber}');
  }

  Future<void> removeWatchHistory(String animeId) async {
    final keysToRemove = _watchHistoryBox.keys.where((key) {
      final entry = _watchHistoryBox.get(key);
      return entry?.animeId == animeId;
    }).toList();
    for (final key in keysToRemove) {
      await _watchHistoryBox.delete(key);
    }
  }

  WatchHistoryModel? getLatestWatchForAnime(String animeId) {
    final entries = _watchHistoryBox.values
        .where((e) => e.animeId == animeId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.isNotEmpty ? entries.first : null;
  }
}
