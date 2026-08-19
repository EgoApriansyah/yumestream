import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/komik_model.dart';
import 'home_provider.dart';

// ─── PAGINATION STATE ──────────────────────────────────────
class ComicPaginationState {
  final List<ComicModel> comics;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ComicPaginationState({
    this.comics = const [],
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ComicPaginationState copyWith({
    List<ComicModel>? comics,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return ComicPaginationState(
      comics: comics ?? this.comics,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

// ─── PAGINATION NOTIFIER ───────────────────────────────────
class ComicPaginationNotifier extends StateNotifier<ComicPaginationState> {
  final Ref _ref;
  final String _type;

  ComicPaginationNotifier(this._ref, this._type)
      : super(const ComicPaginationState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(animeRepositoryProvider);
      final list = await repo.getComicByType(_type, page: 1);
      state = state.copyWith(
        comics: list,
        currentPage: 1,
        isLoading: false,
        hasMore: list.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final repo = _ref.read(animeRepositoryProvider);
      final newComics = await repo.getComicByType(_type, page: nextPage);

      if (newComics.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
      } else {
        // Prevent duplicate items
        final existingIds = state.comics.map((c) => c.mangaId).toSet();
        final filteredNew =
            newComics.where((c) => !existingIds.contains(c.mangaId)).toList();

        state = state.copyWith(
          comics: [...state.comics, ...filteredNew],
          currentPage: nextPage,
          isLoadingMore: false,
          hasMore: newComics.isNotEmpty,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final comicPaginationProvider = StateNotifierProvider.family<
    ComicPaginationNotifier, ComicPaginationState, String>((ref, type) {
  return ComicPaginationNotifier(ref, type);
});

// ─── DETAIL & CHAPTER PROVIDERS ────────────────────────────
final comicDetailProvider =
    FutureProvider.family<ComicDetailModel, String>((ref, slug) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicDetail(slug);
});

final comicChapterImagesProvider =
    FutureProvider.family<ComicChapterImagesModel, String>((ref, slug) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicChapterImages(slug);
});

final comicChapterNavigationProvider =
    FutureProvider.family<ComicChapterNavigationModel, String>((ref, slug) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicChapterNavigation(slug);
});

final comicSearchProvider =
    FutureProvider.family<List<ComicModel>, String>((ref, query) async {
  final repo = ref.read(animeRepositoryProvider);
  if (query.isEmpty) return [];
  return repo.searchComic(query);
});

final comicLatestProvider = FutureProvider<List<ComicModel>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicLatest();
});

final comicPopulerProvider = FutureProvider<List<ComicModel>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicPopuler();
});

final comicTrendingProvider = FutureProvider<List<ComicModel>>((ref) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicTrending();
});

final comicByTypeProvider =
    FutureProvider.family<List<ComicModel>, String>((ref, type) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicByType(type);
});

final comicByGenreProvider =
    FutureProvider.family<List<ComicModel>, String>((ref, genre) async {
  final repo = ref.read(animeRepositoryProvider);
  return repo.getComicByGenre(genre);
});
