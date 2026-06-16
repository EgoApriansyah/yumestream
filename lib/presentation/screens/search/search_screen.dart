import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/debouncer.dart';
import '../../providers/search_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/genre_tag.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/error_widget.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final focusNode = useFocusNode();
    final debouncer = useMemoized(() => Debouncer(milliseconds: 400));
    final query = ref.watch(searchQueryProvider);
    final genresAsync = ref.watch(genresProvider);

    useEffect(() {
      focusNode.requestFocus();
      return debouncer.dispose;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          focusNode: focusNode,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Cari anime...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, color: AppColors.textMuted),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(IconsaxPlusLinear.close_circle, color: AppColors.textMuted),
                    onPressed: () {
                      searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            debouncer.run(() {
              ref.read(searchQueryProvider.notifier).state = value;
            });
          },
        ),
      ),
      body: query.isEmpty
          ? _buildGenresList(genresAsync)
          : _buildSearchResults(ref),
    );
  }

  Widget _buildGenresList(AsyncValue genresAsync) {
    return genresAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Gagal memuat genre')),
      data: (genres) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jelajahi Genre', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: genres.map<Widget>((genre) {
                return GenreTag.fromModel(
                  genre: genre,
                  onTap: () => debugPrint('Navigate to genre ${genre.title}'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(WidgetRef ref) {
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return searchResultsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerGrid(),
      ),
      error: (error, stack) => AppErrorWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada hasil ditemukan',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final anime = results[index];
            return AnimeCard(
              anime: anime,
              onTap: () => context.push('/detail/${anime.animeId}'),
            );
          },
        );
      },
    );
  }
}
