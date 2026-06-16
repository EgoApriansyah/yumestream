import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/anime_detail_model.dart';
import 'home_provider.dart';

// ─── Anime Detail Provider ──────────────────────────────
final animeDetailProvider =
    FutureProvider.family<AnimeDetailModel, String>((ref, slug) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getAnimeDetail(slug);
});
