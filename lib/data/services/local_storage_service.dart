import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/watch_history_model.dart';

class LocalStorageService {
  static const String _watchlistBoxName = 'watchlist';
  static const String _watchHistoryBoxName = 'watch_history';

  late Box<WatchlistItemModel> _watchlistBox;
  late Box<WatchHistoryModel> _watchHistoryBox;

  Future<void> init() async {
    _watchlistBox = await Hive.openBox<WatchlistItemModel>(_watchlistBoxName);
    _watchHistoryBox =
        await Hive.openBox<WatchHistoryModel>(_watchHistoryBoxName);
  }

  // ─── WATCHLIST ────────────────────────────────────────
  List<WatchlistItemModel> getWatchlist() {
    return _watchlistBox.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  bool isInWatchlist(String animeId) {
    return _watchlistBox.containsKey(animeId);
  }

  Future<void> addToWatchlist(WatchlistItemModel item) async {
    await _watchlistBox.put(item.animeId, item);
    debugPrint('Added to watchlist: ${item.title}');
  }

  Future<void> removeFromWatchlist(String animeId) async {
    await _watchlistBox.delete(animeId);
    debugPrint('Removed from watchlist: $animeId');
  }

  Future<void> toggleWatchlist(WatchlistItemModel item) async {
    if (isInWatchlist(item.animeId)) {
      await removeFromWatchlist(item.animeId);
    } else {
      await addToWatchlist(item);
    }
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
