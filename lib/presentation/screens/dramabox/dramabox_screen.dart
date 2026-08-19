import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/dramabox_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_card.dart';

class DramaBoxScreen extends ConsumerWidget {
  const DramaBoxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foryouAsync = ref.watch(dramaboxForyouProvider(1));
    final latestAsync = ref.watch(dramaboxLatestProvider);
    final trendingAsync = ref.watch(dramaboxTrendingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('DramaBox', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dramaboxForyouProvider(1));
          ref.invalidate(dramaboxLatestProvider);
          ref.invalidate(dramaboxTrendingProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── TRENDING SECTION ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text('Drama Populer 🔥', style: AppTextStyles.titleMedium),
              ),
              SizedBox(
                height: 180,
                child: trendingAsync.when(
                  loading: () => _buildHorizontalShimmerList(),
                  error: (err, _) => Center(child: Text(err.toString(), style: AppTextStyles.body.copyWith(color: AppColors.error))),
                  data: (dramas) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: dramas.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final drama = dramas[index];
                      return GestureDetector(
                        onTap: () => context.push('/dramabox/detail/${drama.bookId}'),
                        child: SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppCachedImage(
                                  imageUrl: drama.coverWap,
                                  borderRadius: 12,
                                  width: 110,
                                  height: 150,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                drama.bookName,
                                style: AppTextStyles.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── LATEST SECTION ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Terbaru', style: AppTextStyles.titleMedium),
              ),
              SizedBox(
                height: 180,
                child: latestAsync.when(
                  loading: () => _buildHorizontalShimmerList(),
                  error: (err, _) => Center(child: Text(err.toString(), style: AppTextStyles.body.copyWith(color: AppColors.error))),
                  data: (dramas) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: dramas.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final drama = dramas[index];
                      return GestureDetector(
                        onTap: () => context.push('/dramabox/detail/${drama.bookId}'),
                        child: SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppCachedImage(
                                  imageUrl: drama.coverWap,
                                  borderRadius: 12,
                                  width: 110,
                                  height: 150,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                drama.bookName,
                                style: AppTextStyles.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── RECOMMENDATIONS (FOR YOU) SECTION ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Rekomendasi Untukmu ✨', style: AppTextStyles.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: foryouAsync.when(
                  loading: () => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => const ShimmerCard(width: 110, height: 180),
                  ),
                  error: (err, _) => AppErrorWidget(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(dramaboxForyouProvider(1)),
                  ),
                  data: (dramas) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: dramas.length,
                    itemBuilder: (context, index) {
                      final drama = dramas[index];
                      return GestureDetector(
                        onTap: () => context.push('/dramabox/detail/${drama.bookId}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppCachedImage(
                                imageUrl: drama.coverWap,
                                borderRadius: 12,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              drama.bookName,
                              style: AppTextStyles.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${drama.chapterCount} Eps',
                              style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => const ShimmerCard(width: 110, height: 150),
    );
  }
}
