import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/dramabox_provider.dart';
import '../../widgets/error_widget.dart';

class DramaBoxPlayerScreen extends HookConsumerWidget {
  final String bookId;
  final String chapterId;
  final String? title;
  final int episodeIndex;
  final String episodeName;

  const DramaBoxPlayerScreen({
    super.key,
    required this.bookId,
    required this.chapterId,
    this.title,
    required this.episodeIndex,
    required this.episodeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(dramaboxEpisodesProvider(bookId));
    final controller = useMemoized(() {
      return WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: episodesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(dramaboxEpisodesProvider(bookId)),
        ),
        data: (episodes) {
          final currentEpisode = episodes.firstWhere(
            (e) => e.chapterId == chapterId,
            orElse: () => episodes[episodeIndex < episodes.length ? episodeIndex : 0],
          );

          // Get default encrypted video URL
          String encUrl = '';
          if (currentEpisode.cdnList.isNotEmpty) {
            final cdn = currentEpisode.cdnList.firstWhere((c) => c.isDefault == 1, orElse: () => currentEpisode.cdnList.first);
            if (cdn.videoPathList.isNotEmpty) {
              final vp = cdn.videoPathList.firstWhere((v) => v.isDefault == 1, orElse: () => cdn.videoPathList.first);
              encUrl = vp.videoPath;
            }
          }

          if (encUrl.isEmpty) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: Text('Video tidak tersedia', style: TextStyle(color: Colors.white))),
            );
          }

          final decryptAsync = ref.watch(dramaboxDecryptProvider(encUrl));

          return decryptAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Gagal mendekripsi video: $err',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ),
            data: (decrypted) {
              // Load video HTML string into webview
              useEffect(() {
                if (decrypted.streamUrl.isNotEmpty) {
                  controller.loadHtmlString('''
                    <!DOCTYPE html>
                    <html>
                    <head>
                      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                      <style>
                        body, html { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: black; }
                        video { width: 100%; height: 100%; object-fit: contain; }
                      </style>
                    </head>
                    <body>
                      <video autoplay controls playsinline loop>
                        <source src="${decrypted.streamUrl}" type="video/mp4">
                      </video>
                    </body>
                    </html>
                  ''');
                }
                return null;
              }, [decrypted.streamUrl]);

              final hasPrev = episodeIndex > 0;
              final hasNext = episodeIndex < episodes.length - 1;

              return SafeArea(
                child: Column(
                  children: [
                    // Vertical Player 9:16
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Stack(
                            children: [
                              WebViewWidget(controller: controller),
                              Positioned(
                                top: 16,
                                left: 16,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () => context.pop(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Controls at bottom
                    Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            currentEpisode.chapterName,
                            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.elevated,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.surface.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: hasPrev
                                      ? () {
                                          final prevEp = episodes[episodeIndex - 1];
                                          context.pushReplacement(
                                            '/dramabox/player/$bookId/${prevEp.chapterId}',
                                            extra: {
                                              'title': title,
                                              'epIndex': episodeIndex - 1,
                                              'epName': prevEp.chapterName,
                                            },
                                          );
                                        }
                                      : null,
                                  child: const Text('Sebelumnya'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.surface.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: hasNext
                                      ? () {
                                          final nextEp = episodes[episodeIndex + 1];
                                          context.pushReplacement(
                                            '/dramabox/player/$bookId/${nextEp.chapterId}',
                                            extra: {
                                              'title': title,
                                              'epIndex': episodeIndex + 1,
                                              'epName': nextEp.chapterName,
                                            },
                                          );
                                        }
                                      : null,
                                  child: const Text('Selanjutnya'),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
