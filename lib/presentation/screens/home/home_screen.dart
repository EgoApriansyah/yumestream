import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/home_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/cached_image.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider);
    final watchHistory = ref.watch(watchHistoryProvider);
    final todaySchedule = ref.watch(todayScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('YumeStream', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.notification),
            onPressed: () {},
          ),
        ],
      ),
      body: homeData.when(
        loading: () => const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerCard(width: 140, height: 24),
              ),
              SizedBox(height: 16),
              ShimmerList(),
              SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerCard(width: 140, height: 24),
              ),
              SizedBox(height: 16),
              ShimmerList(),
            ],
          ),
        ),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
        data: (data) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Continue Watching Section
              if (watchHistory.isNotEmpty) ...[
                SectionHeader(title: 'Lanjut Nonton'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: watchHistory.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final history = watchHistory[index];
                      return ProgressCard(
                        history: history,
                        onTap: () => context.push('/player/${history.episodeId}', extra: {
                          'poster': history.poster,
                          'animeTitle': history.animeTitle,
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Ongoing Anime Section
              SectionHeader(
                title: 'Anime Ongoing',
                onSeeAll: () => context.push('/list/ongoing'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.ongoing.animeList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final anime = data.ongoing.animeList[index];
                    return SizedBox(
                      width: 140,
                      child: AnimeCard(
                        anime: anime,
                        onTap: () => context.push('/detail/${anime.animeId}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Completed Anime Section
              SectionHeader(
                title: 'Baru Tamat',
                onSeeAll: () => context.push('/list/complete'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.completed.animeList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final anime = data.completed.animeList[index];
                    return SizedBox(
                      width: 140,
                      child: AnimeCard(
                        anime: anime,
                        onTap: () => context.push('/detail/${anime.animeId}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Today's Schedule Section
              SectionHeader(title: 'Jadwal Hari Ini'),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: todaySchedule.when(
                  loading: () => const ShimmerList(itemWidth: 120, itemHeight: 180),
                  error: (_, __) => const Center(child: Text('Gagal memuat jadwal')),
                  data: (scheduleList) {
                    if (scheduleList.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada anime tayang hari ini',
                          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: scheduleList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final anime = scheduleList[index];
                        return GestureDetector(
                          onTap: () => context.push('/detail/${anime.animeId}'),
                          child: SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppCachedImage(
                                  imageUrl: anime.poster,
                                  width: 120,
                                  height: 160,
                                  borderRadius: 12,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  anime.title,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
