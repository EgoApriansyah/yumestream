import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/home_provider.dart';
import '../../widgets/anime_card.dart';
import '../../../data/models/anime_model.dart';

class WatchlistScreen extends HookConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist', style: AppTextStyles.titleLarge),
      ),
      body: watchlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(IconsaxPlusLinear.bookmark, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('Belum ada anime tersimpan', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.go('/main/home'),
                    child: const Text('Eksplor Anime'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: watchlist.length,
              itemBuilder: (context, index) {
                final item = watchlist[index];
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
                        title: Text('Hapus dari Watchlist', style: AppTextStyles.titleMedium),
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
            ),
    );
  }
}
