import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/episode_detail_model.dart';
import 'home_provider.dart';

// ─── Episode Detail Provider ────────────────────────────
final episodeDetailProvider =
    FutureProvider.family<EpisodeDetailModel, String>((ref, slug) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getEpisodeDetail(slug);
});

// ─── Selected Server ────────────────────────────────────
final selectedServerIdProvider = StateProvider<String?>((ref) => null);

// ─── Streaming URL Provider ─────────────────────────────
final streamingUrlProvider =
    FutureProvider.family<String, String>((ref, serverId) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getServerUrl(serverId);
});
