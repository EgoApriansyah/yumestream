import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/anime_model.dart';
import '../../data/models/pagination_model.dart';
import 'home_provider.dart';

enum SortMode { defaultSort, az, za, highestRating }

class AnimeListState {
  final List<AnimeModel> items;
  final SortMode sortMode;
  final bool isLoading;
  final bool isFetchingNext;
  final bool hasReachedMax;
  final int currentPage;
  final String? error;

  AnimeListState({
    required this.items,
    this.sortMode = SortMode.defaultSort,
    this.isLoading = false,
    this.isFetchingNext = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.error,
  });

  AnimeListState copyWith({
    List<AnimeModel>? items,
    SortMode? sortMode,
    bool? isLoading,
    bool? isFetchingNext,
    bool? hasReachedMax,
    int? currentPage,
    String? error,
  }) {
    return AnimeListState(
      items: items ?? this.items,
      sortMode: sortMode ?? this.sortMode,
      isLoading: isLoading ?? this.isLoading,
      isFetchingNext: isFetchingNext ?? this.isFetchingNext,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }

  List<AnimeModel> get sortedItems {
    if (items.isEmpty) return items;
    final list = List<AnimeModel>.from(items);
    switch (sortMode) {
      case SortMode.az:
        list.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      case SortMode.za:
        list.sort((a, b) => (b.title ?? '').compareTo(a.title ?? ''));
        break;
      case SortMode.highestRating:
        list.sort((a, b) {
          final scoreA = double.tryParse(a.score ?? '0') ?? 0.0;
          final scoreB = double.tryParse(b.score ?? '0') ?? 0.0;
          return scoreB.compareTo(scoreA);
        });
        break;
      case SortMode.defaultSort:
      default:
        // Keep original API order
        break;
    }
    return list;
  }
}

class AnimeListNotifier extends AutoDisposeFamilyNotifier<AnimeListState, String> {
  @override
  AnimeListState build(String arg) {
    Future.microtask(() => loadInitial());
    return AnimeListState(items: [], isLoading: true);
  }

  void setSortMode(SortMode mode) {
    state = state.copyWith(sortMode: mode);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(animeRepositoryProvider);
      
      final ({List<AnimeModel> animeList, PaginationModel? pagination}) result;
      if (arg == 'ongoing') {
        result = await repo.getOngoingAnime(page: 1);
      } else if (arg == 'complete') {
        result = await repo.getCompleteAnime(page: 1);
      } else if (arg.startsWith('genre:')) {
        final slug = arg.substring(6);
        result = await repo.getGenreAnime(slug, page: 1);
      } else {
        throw Exception('Tipe daftar tidak valid');
      }
          
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
      
      final ({List<AnimeModel> animeList, PaginationModel? pagination}) result;
      if (arg == 'ongoing') {
        result = await repo.getOngoingAnime(page: nextPage);
      } else if (arg == 'complete') {
        result = await repo.getCompleteAnime(page: nextPage);
      } else if (arg.startsWith('genre:')) {
        final slug = arg.substring(6);
        result = await repo.getGenreAnime(slug, page: nextPage);
      } else {
        throw Exception('Tipe daftar tidak valid');
      }
          
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
