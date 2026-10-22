import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/komik_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_card.dart';

class KomikScreen extends HookConsumerWidget {
  const KomikScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState<String>('');
    final tabController = useTabController(initialLength: 4);

    // Debounce search input
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Komik', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ─── SEARCH BAR ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari komik (contoh: Solo Leveling)...',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // If search query is not empty, show search results
          if (searchQuery.value.isNotEmpty)
            Expanded(
              child: _ComicSearchResults(query: searchQuery.value),
            )
          else ...[
            // ─── TAB BAR ───────────────────────────────────────────
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: AppTextStyles.label,
              tabs: const [
                Tab(text: 'Terbaru'),
                Tab(text: 'Manga'),
                Tab(text: 'Manhwa'),
                Tab(text: 'Manhua'),
              ],
            ),
            const Divider(height: 1, color: AppColors.divider),

            // ─── TAB BAR VIEW ──────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [
                  _ComicGridTab(type: 'terbaru'),
                  _ComicGridTab(type: 'manga'),
                  _ComicGridTab(type: 'manhwa'),
                  _ComicGridTab(type: 'manhua'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── COMIC GRID TAB WITH INFINITE SCROLL ──────────────────────
class _ComicGridTab extends HookConsumerWidget {
  final String type;

  const _ComicGridTab({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(comicPaginationProvider(type));
    final scrollController = useScrollController();

    // Attach infinite scroll listener
    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        // Trigger loadMore when near the bottom (200px threshold)
        if (currentScroll >= maxScroll - 200) {
          ref.read(comicPaginationProvider(type).notifier).loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(comicPaginationProvider(type).notifier).refresh();
      },
      child: Builder(
        builder: (context) {
          if (state.isLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: 8,
              itemBuilder: (_, _) => const ShimmerCard(width: 110, height: 180),
            );
          }

          if (state.error != null && state.comics.isEmpty) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () =>
                  ref.read(comicPaginationProvider(type).notifier).refresh(),
            );
          }

          if (state.comics.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada komik ditemukan',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comic = state.comics[index];
                      return GestureDetector(
                        onTap: () => context.push('/komik/detail/${comic.mangaId}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppCachedImage(
                                imageUrl: comic.coverImageUrl,
                                borderRadius: 12,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comic.title,
                              style: AppTextStyles.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comic.latestChapterNumber != null &&
                                      comic.latestChapterNumber!.isNotEmpty
                                  ? 'Ch. ${comic.latestChapterNumber}'
                                  : '⭐ ${comic.userRate > 0 ? comic.userRate.toStringAsFixed(1) : "-"}',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.accent),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: state.comics.length,
                  ),
                ),
              ),
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── SEARCH RESULTS WIDGET ──────────────────────────────────────
class _ComicSearchResults extends ConsumerWidget {
  final String query;

  const _ComicSearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(comicSearchProvider(query));

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Gagal mencari: $err',
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      ),
      data: (comics) {
        if (comics.isEmpty) {
          return Center(
            child: Text(
              'Komik "$query" tidak ditemukan.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: comics.length,
          separatorBuilder: (_, _) =>
              const Divider(color: AppColors.divider, height: 24),
          itemBuilder: (context, index) {
            final comic = comics[index];
            return GestureDetector(
              onTap: () => context.push('/komik/detail/${comic.mangaId}'),
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCachedImage(
                    imageUrl: comic.coverImageUrl,
                    width: 70,
                    height: 100,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comic.title,
                          style: AppTextStyles.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (comic.latestChapterNumber != null &&
                            comic.latestChapterNumber!.isNotEmpty)
                          Text(
                            'Chapter Terbaru: ${comic.latestChapterNumber}',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.accent),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Rating: ⭐ ${comic.userRate > 0 ? comic.userRate.toStringAsFixed(1) : "-"}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
