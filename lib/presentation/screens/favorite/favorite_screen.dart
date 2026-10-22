import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/anime_model.dart';
import '../../../data/models/komik_model.dart';
import '../../providers/home_provider.dart';
import '../../providers/komik_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/cached_image.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeFavorites = ref.watch(watchlistProvider);
    final comicFavorites = ref.watch(comicFavoritesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Favorit', style: AppTextStyles.titleLarge),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.label,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(IconsaxPlusLinear.video_play, size: 18),
                    const SizedBox(width: 8),
                    Text('Anime (${animeFavorites.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(IconsaxPlusLinear.book, size: 18),
                    const SizedBox(width: 8),
                    Text('Komik (${comicFavorites.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ─── TAB 1: ANIME FAVORITES ───────────────────────
            _AnimeFavoritesTab(items: animeFavorites),

            // ─── TAB 2: COMIC FAVORITES ───────────────────────
            _ComicFavoritesTab(items: comicFavorites),
          ],
        ),
      ),
    );
  }
}

class _AnimeFavoritesTab extends ConsumerWidget {
  final List dynamicItems;

  const _AnimeFavoritesTab({required this.items}) : dynamicItems = items;
  final dynamic items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeList = ref.watch(watchlistProvider);

    if (animeList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(IconsaxPlusLinear.video_play, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Belum ada anime favorit tersimpan',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(IconsaxPlusLinear.discover_1, size: 18),
                onPressed: () => context.go('/main/home'),
                label: const Text('Eksplor Anime'),
              ),
            ],
          ),
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
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final item = animeList[index];
        final anime = AnimeModel(
          title: item.title,
          poster: item.poster,
          animeId: item.animeId,
          href: '',
          score: item.score,
          status: item.status,
        );

        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text('Hapus dari Favorit', style: AppTextStyles.titleMedium),
                content: Text('Yakin ingin menghapus ${item.title}?', style: AppTextStyles.body),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(watchlistProvider.notifier).remove(item.animeId);
                      Navigator.pop(context);
                    },
                    child: Text('Hapus', style: AppTextStyles.label.copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
          child: AnimeCard(
            anime: anime,
            onTap: () => context.push('/detail/${anime.animeId}'),
          ),
        );
      },
    );
  }
}

class _ComicFavoritesTab extends ConsumerWidget {
  final List<ComicModel> items;

  const _ComicFavoritesTab({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(IconsaxPlusLinear.book, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Belum ada komik favorit tersimpan',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(IconsaxPlusLinear.discover_1, size: 18),
                onPressed: () => context.go('/main/komik'),
                label: const Text('Eksplor Komik'),
              ),
            ],
          ),
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final comic = items[index];

        return GestureDetector(
          onTap: () => context.push('/komik/detail/${comic.mangaId}'),
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text('Hapus dari Favorit', style: AppTextStyles.titleMedium),
                content: Text('Yakin ingin menghapus ${comic.title}?', style: AppTextStyles.body),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(comicFavoritesProvider.notifier).remove(comic.mangaId);
                      Navigator.pop(context);
                    },
                    child: Text('Hapus', style: AppTextStyles.label.copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    AppCachedImage(
                      imageUrl: comic.coverImageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 12,
                    ),
                    if (comic.type != null && comic.type!.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.5),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            comic.type!.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (comic.latestChapterNumber != null && comic.latestChapterNumber!.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            comic.latestChapterNumber!,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                comic.title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
