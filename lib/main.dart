import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'data/models/watch_history_model.dart';
import 'data/services/local_storage_service.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/detail/anime_detail_screen.dart';
import 'presentation/screens/player/episode_player_screen.dart';
import 'presentation/screens/watchlist/watchlist_screen.dart';
import 'presentation/screens/schedule/schedule_screen.dart';
import 'presentation/screens/anime_list/anime_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(WatchHistoryModelAdapter());
  Hive.registerAdapter(WatchlistItemModelAdapter());

  // Initialize local storage
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const YumeStreamApp(),
    ),
  );
}

class YumeStreamApp extends StatelessWidget {
  const YumeStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'YumeStream',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/main/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/main/search',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: '/main/watchlist',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WatchlistScreen(),
          ),
        ),
        GoRoute(
          path: '/main/schedule',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScheduleScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/detail/:animeId',
      builder: (context, state) {
        final animeId = state.pathParameters['animeId']!;
        return AnimeDetailScreen(animeId: animeId);
      },
    ),
    GoRoute(
      path: '/player/:episodeId',
      builder: (context, state) {
        final episodeId = state.pathParameters['episodeId']!;
        final extra = state.extra as Map?;
        final poster = extra?['poster']?.toString();
        final animeTitle = extra?['animeTitle']?.toString();
        return EpisodePlayerScreen(
          episodeId: episodeId, 
          poster: poster,
          animeTitle: animeTitle,
        );
      },
    ),
    GoRoute(
      path: '/list/:type',
      builder: (context, state) {
        final type = state.pathParameters['type']!;
        return AnimeListScreen(listType: type);
      },
    ),
  ],
);
