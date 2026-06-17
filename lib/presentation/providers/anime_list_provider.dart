import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/anime_model.dart';
import 'home_provider.dart';

class AnimeListState {
  final List<AnimeModel> items;
  final bool isLoading;
  final bool isFetchingNext;
  final bool hasReachedMax;
  final int currentPage;
  final String? error;

  AnimeListState({
    required this.items,
    this.isLoading = false,
    this.isFetchingNext = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.error,
  });

  AnimeListState copyWith({
    List<AnimeModel>? items,
    bool? isLoading,
    bool? isFetchingNext,
    bool? hasReachedMax,
    int? currentPage,
    String? error,
  }) {
    return AnimeListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isFetchingNext: isFetchingNext ?? this.isFetchingNext,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

class AnimeListNotifier extends AutoDisposeFamilyNotifier<AnimeListState, String> {
  @override
  AnimeListState build(String arg) {
    Future.microtask(() => loadInitial());
    return AnimeListState(items: [], isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(animeRepositoryProvider);
      final result = arg == 'ongoing'
          ? await repo.getOngoingAnime(page: 1)
          : await repo.getCompleteAnime(page: 1);
          
      final hasNext = result.pagination?.nextPage != null;
      
      state = state.copyWith(
        items: result.animeList,
        isLoading: false,
        currentPage: 1,
        hasReachedMax: !hasNext,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNext() async {
    if (state.isLoading || state.isFetchingNext || state.hasReachedMax) return;

    state = state.copyWith(isFetchingNext: true, error: null);
    try {
      final nextPage = state.currentPage + 1;
      final repo = ref.read(animeRepositoryProvider);
      final result = arg == 'ongoing'
          ? await repo.getOngoingAnime(page: nextPage)
          : await repo.getCompleteAnime(page: nextPage);
          
      final hasNext = result.pagination?.nextPage != null;

      state = state.copyWith(
        items: [...state.items, ...result.animeList],
        isFetchingNext: false,
        currentPage: nextPage,
        hasReachedMax: !hasNext,
      );
    } catch (e) {
      state = state.copyWith(
        isFetchingNext: false,
        error: e.toString(),
      );
    }
  }
}

final animeListProvider = AutoDisposeNotifierProviderFamily<AnimeListNotifier, AnimeListState, String>(() {
  return AnimeListNotifier();
});
