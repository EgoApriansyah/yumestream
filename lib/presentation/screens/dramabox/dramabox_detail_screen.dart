import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/dramabox_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';

class DramaBoxDetailScreen extends ConsumerWidget {
  final String bookId;

  const DramaBoxDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(dramaboxDetailProvider(bookId));
    final episodesAsync = ref.watch(dramaboxEpisodesProvider(bookId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Scaffold(
          appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
          body: AppErrorWidget(
            message: err.toString(),
            onRetry: () => ref.invalidate(dramaboxDetailProvider(bookId)),
          ),
        ),
        data: (drama) {
          return CustomScrollView(
            slivers: [
              // ─── APP BAR WITH COVER ────────────────────────────────
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedImage(
                        imageUrl: drama.coverWap,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Dark gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Poster & Metadata layout
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppCachedImage(
                              imageUrl: drama.coverWap,
                              width: 100,
                              height: 140,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    drama.bookName,
                                    style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.tagBackground,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${drama.chapterCount} Episode',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── METADATA & EPISODES LIST ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Synopsis / Introduction
                      Text('Sinopsis', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        drama.introduction.isNotEmpty
                            ? drama.introduction
                            : 'Tidak ada sinopsis untuk drama ini.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      ),
                      
                      const SizedBox(height: 20),

                      // Tags / Genres
                      if (drama.tags.isNotEmpty) ...[
                        Text('Tag', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: drama.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Episodes
                      Text('Daftar Episode', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: episodesAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Gagal memuat daftar episode.',
                        style: AppTextStyles.body.copyWith(color: AppColors.error),
                      ),
                    ),
                  ),
                  data: (episodes) {
                    if (episodes.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'Tidak ada episode yang tersedia.',
                            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }
                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ep = episodes[index];
                          return GestureDetector(
                            onTap: () {
                              context.push(
                                '/dramabox/player/${drama.bookId}/${ep.chapterId}',
                                extra: {
                                  'title': drama.bookName,
                                  'epIndex': index,
                                  'epName': ep.chapterName,
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider, width: 0.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'EP ${ep.chapterIndex + 1}',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: episodes.length,
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          );
        },
      ),
    );
  }
}
