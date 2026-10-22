import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import '../models/komik_model.dart';
import '../models/watch_history_model.dart';
import '../models/anime_detail_model.dart';
import '../services/api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'updates_channel';
  static const String _channelName = 'Update Anime & Komik';
  static const String _channelDescription =
      'Notifikasi saat ada episode anime atau chapter komik terbaru';

  static const String _trackerBoxName = 'favorite_update_tracker';
  late Box _trackerBox;

  // Global navigation handler callback
  Function(String route)? onNotificationTapped;

  Future<void> init({Function(String route)? onSelectNotification}) async {
    onNotificationTapped = onSelectNotification;
    _trackerBox = await Hive.openBox(_trackerBoxName);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onNotificationTapped?.call(payload);
        }
      },
    );

    // Create high-importance Android notification channel
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
    }

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    try {
      // Android 13+
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      // iOS
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // ─── CHECK FOR UPDATES ON FAVORITES ───────────────────
  Future<void> checkForUpdates({
    required List<WatchlistItemModel> animeFavorites,
    required List<ComicModel> comicFavorites,
    required ApiService apiService,
  }) async {
    try {
      // 1. Check Anime Favorites
      for (final anime in animeFavorites) {
        AnimeDetailModel? detail;
        try {
          detail = await apiService.getAnimeDetail(anime.animeId);
        } catch (_) {
          detail = null;
        }

        if (detail != null && detail.episodeList.isNotEmpty) {
          final latestEp = detail.episodeList.first.eps;
          final cacheKey = 'anime_${anime.animeId}';
          final lastKnownEp = _trackerBox.get(cacheKey) as int?;

          if (lastKnownEp == null) {
            // First time tracking this anime, save current latest
            await _trackerBox.put(cacheKey, latestEp);
          } else if (latestEp > lastKnownEp) {
            // New episode released!
            await _trackerBox.put(cacheKey, latestEp);
            await showNotification(
              id: anime.animeId.hashCode,
              title: '🎬 Episode Baru Anime!',
              body: '${anime.title} Episode $latestEp sudah rilis. Tonton sekarang!',
              payload: '/detail/${anime.animeId}',
            );
          }
        }
      }

      // 2. Check Comic Favorites
      for (final comic in comicFavorites) {
        ComicDetailModel? detail;
        try {
          detail = await apiService.getComicDetail(comic.mangaId);
        } catch (_) {
          detail = null;
        }

        if (detail != null && detail.chapters.isNotEmpty) {
          final latestCh = detail.chapters.first.chapterNumber;
          final cacheKey = 'comic_${comic.mangaId}';
          final lastKnownCh = _trackerBox.get(cacheKey)?.toString();

          if (lastKnownCh == null) {
            // First time tracking, save current chapter
            await _trackerBox.put(cacheKey, latestCh);
          } else if (lastKnownCh != latestCh) {
            // New chapter released!
            await _trackerBox.put(cacheKey, latestCh);
            await showNotification(
              id: comic.mangaId.hashCode,
              title: '📖 Chapter Baru Komik!',
              body: '${comic.title} $latestCh sudah rilis. Baca sekarang!',
              payload: '/komik/detail/${comic.mangaId}',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking favorite updates: $e');
    }
  }
}
