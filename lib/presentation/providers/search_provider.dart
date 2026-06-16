import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/anime_model.dart';
import '../../data/models/genre_model.dart';
import 'home_provider.dart';

// ─── Genres Provider ────────────────────────────────────
final genresProvider = FutureProvider<List<GenreModel>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getGenres();
});

// ─── Search Query ───────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

// ─── Search Results ─────────────────────────────────────
final searchResultsProvider =
    FutureProvider.autoDispose<List<AnimeModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.read(animeRepositoryProvider);
  return repo.searchAnime(query.trim());
});
