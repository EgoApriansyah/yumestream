import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/anime_detail_provider.dart';
import '../../providers/home_provider.dart';
import '../../../data/models/watch_history_model.dart';
import '../../widgets/episode_chip.dart';
import '../../widgets/genre_tag.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_card.dart';

class AnimeDetailScreen extends HookConsumerWidget {
  final String animeId;

  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(animeDetailProvider(animeId));
    final isSynopsisExpanded = useState(false);

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(animeDetailProvider(animeId)),
        ),
        data: (detail) {
          final watchlist = ref.watch(watchlistProvider);
          final isWatchlisted = watchlist.any((item) => item.animeId == animeId);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedImage(
                        imageUrl: detail.poster,
                        width: double.infinity,
                        height: 300,
                        borderRadius: 0,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, AppColors.background],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail.title, style: AppTextStyles.titleLarge),
                      if (detail.japanese.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          detail.japanese,
                          style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (detail.score != null && detail.score!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.ratingAmber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(IconsaxPlusBold.star, size: 14, color: AppColors.ratingAmber),
                                  const SizedBox(width: 4),
                                  Text(
                                    detail.score!,
                                    style: AppTextStyles.caption.copyWith(color: AppColors.ratingAmber),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: detail.status == 'Ongoing' 
                                  ? AppColors.accent.withValues(alpha: 0.2)
                                  : AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              detail.status ?? 'Unknown',
                              style: AppTextStyles.caption.copyWith(
                                color: detail.status == 'Ongoing' ? AppColors.accent : AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (detail.episodes != null)
                            Text('${detail.episodes} Episode', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: detail.genreList.map((genre) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GenreTag.fromModel(
                              genre: genre,
                              onTap: () {
                                if (genre.genreId != null) {
                                  context.push('/list/genre:${genre.genreId}?title=${Uri.encodeComponent(genre.title ?? 'Genre')}');
                                }
                              },
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (detail.synopsis != null) ...[
                        Text(
                          detail.synopsis!.fullText,
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          maxLines: isSynopsisExpanded.value ? null : 3,
                          overflow: isSynopsisExpanded.value ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => isSynopsisExpanded.value = !isSynopsisExpanded.value,
                            child: Text(
                              isSynopsisExpanded.value ? 'Tutup' : 'Baca selengkapnya',
                              style: AppTextStyles.label.copyWith(color: AppColors.accent),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isWatchlisted ? AppColors.surface : AppColors.accent,
                                foregroundColor: isWatchlisted ? AppColors.accent : AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: Icon(isWatchlisted ? IconsaxPlusBold.bookmark : IconsaxPlusLinear.bookmark),
                              label: Text(isWatchlisted ? 'Tersimpan' : 'Tambah ke Watchlist'),
                              onPressed: () {
                                final item = WatchlistItemModel(
                                  animeId: animeId,
                                  title: detail.title,
                                  poster: detail.poster,
                                  score: detail.score,
                                  status: detail.status,
                                );
                                ref.read(watchlistProvider.notifier).toggle(item);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isWatchlisted ? 'Dihapus dari Watchlist' : 'Ditambahkan ke Watchlist'),
                                    backgroundColor: isWatchlisted ? AppColors.surface : AppColors.success,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (detail.batch != null) ...[
                            const SizedBox(width: 12),
                            IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(IconsaxPlusLinear.document_download, color: AppColors.textPrimary),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.card,
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Unduh Batch', style: AppTextStyles.titleMedium),
                                        const SizedBox(height: 16),
                                        Text('Fitur batch belum diimplementasikan.', style: AppTextStyles.body),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text('Episode', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: detail.episodeList.map((ep) => EpisodeChip(
                          episodeNumber: ep.eps,
                          onTap: () => context.push('/player/${ep.episodeId}', extra: {
                            'poster': detail.poster,
                            'animeTitle': detail.title,
                          }),
                        )).toList(),
                      ),
                      const SizedBox(height: 48),
                    ],
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
