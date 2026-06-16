import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/episode_provider.dart';
import '../../providers/home_provider.dart';
import '../../../data/models/watch_history_model.dart';
import '../../widgets/error_widget.dart';

class EpisodePlayerScreen extends HookConsumerWidget {
  final String episodeId;
  final String? poster;
  final String? animeTitle;

  const EpisodePlayerScreen({
    super.key, 
    required this.episodeId, 
    this.poster, 
    this.animeTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeAsync = ref.watch(episodeDetailProvider(episodeId));
    final controller = useMemoized(() {
      final ctrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.background);
      
      if (ctrl.platform is AndroidWebViewController) {
        (ctrl.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }
      
      return ctrl;
    });

    useEffect(() {
      return () {
        // cleanup/save history handled via provider listener if needed, 
        // but simplified here for direct access if data is loaded
      };
    }, []);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: episodeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(episodeDetailProvider(episodeId)),
        ),
        data: (episode) {
          // Save history on data load
          useEffect(() {
            Future.microtask(() {
              ref.read(watchHistoryProvider.notifier).saveHistory(
                WatchHistoryModel(
                  animeId: episode.animeId,
                  animeTitle: animeTitle ?? episode.title, 
                  poster: poster ?? '', // Use passed poster
                  episodeId: episodeId,
                  episodeNumber: episode.info?.episodeList.firstWhere((e) => e.episodeId == episodeId, orElse: () => episode.info!.episodeList.first).eps ?? 0,
                )
              );
            });
            return null;
          }, [episodeId]);

          final selectedServerId = useState<String?>(null);
          
          // Initial load
          useEffect(() {
            if (episode.defaultStreamingUrl != null) {
              controller.loadRequest(Uri.parse(episode.defaultStreamingUrl!));
            }
            return null;
          }, [episode.defaultStreamingUrl]);

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: WebViewWidget(controller: controller),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(episode.title, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 16),
                        if (episode.server != null) ...[
                          Text('Pilih Server', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          ...episode.server!.qualities.map((q) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q.title, style: AppTextStyles.caption),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: q.serverList.map((s) {
                                    final isSelected = selectedServerId.value == s.serverId;
                                    return GestureDetector(
                                      onTap: () async {
                                        if (selectedServerId.value == s.serverId) return;
                                        selectedServerId.value = s.serverId;
                                        try {
                                          final url = await ref.read(streamingUrlProvider(s.serverId).future);
                                          if (context.mounted && url.isNotEmpty) {
                                            controller.loadRequest(Uri.parse(url));
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Gagal memuat server')),
                                            );
                                            selectedServerId.value = null;
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.accent : AppColors.surface,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s.title,
                                          style: AppTextStyles.label.copyWith(
                                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (episode.hasPrevEpisode && episode.prevEpisode != null)
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surface,
                                    foregroundColor: AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => context.pushReplacement('/player/${episode.prevEpisode!.episodeId}'),
                                  child: const Text('Sebelumnya'),
                                ),
                              ),
                            if (episode.hasPrevEpisode && episode.hasNextEpisode)
                              const SizedBox(width: 16),
                            if (episode.hasNextEpisode && episode.nextEpisode != null)
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => context.pushReplacement('/player/${episode.nextEpisode!.episodeId}'),
                                  child: const Text('Selanjutnya'),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
