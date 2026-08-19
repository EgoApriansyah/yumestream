import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dramabox_model.dart';
import 'home_provider.dart';

final dramaboxForyouProvider = FutureProvider.family<List<DramaBoxBookModel>, int>((ref, page) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getDramaBoxForyou(page: page);
});

final dramaboxLatestProvider = FutureProvider<List<DramaBoxBookModel>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getDramaBoxLatest();
});

final dramaboxTrendingProvider = FutureProvider<List<DramaBoxBookModel>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getDramaBoxTrending();
});

final dramaboxDetailProvider = FutureProvider.family<DramaBoxBookModel, String>((ref, bookId) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getDramaBoxDetail(bookId);
});

final dramaboxEpisodesProvider = FutureProvider.family<List<DramaBoxEpisodeModel>, String>((ref, bookId) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getDramaBoxEpisodes(bookId);
});

final dramaboxDecryptProvider = FutureProvider.family<DramaBoxDecryptedModel, String>((ref, url) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.decryptDramaBoxUrl(url);
});
