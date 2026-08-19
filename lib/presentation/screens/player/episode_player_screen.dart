import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _restoreSystemUI() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeAsync = ref.watch(episodeDetailProvider(episodeId));
    final isLocked = useState<bool>(false);
    final customWidget = useState<Widget?>(null);
    final onHideCustomWidgetCallback = useState<VoidCallback?>(null);

    final controller = useMemoized(() {
      final ctrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black);

      if (ctrl.platform is AndroidWebViewController) {
        final androidCtrl = ctrl.platform as AndroidWebViewController;
        androidCtrl.setMediaPlaybackRequiresUserGesture(false);
        androidCtrl.setCustomWidgetCallbacks(
          onShowCustomWidget: (Widget widget, void Function() onHideCustomWidget) {
            customWidget.value = widget;
            onHideCustomWidgetCallback.value = onHideCustomWidget;
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          },
          onHideCustomWidget: () {
            customWidget.value = null;
            onHideCustomWidgetCallback.value = null;
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          },
        );
      }

      return ctrl;
    });

    // Cleanup System UI and Orientations on dispose
    useEffect(() {
      return () {
        _restoreSystemUI();
      };
    }, []);

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isFullscreen = isLandscape || customWidget.value != null;

    // Fullscreen Immersive Handling
    useEffect(() {
      if (isFullscreen || isLocked.value) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
      return null;
    }, [isFullscreen, isLocked.value]);

    return PopScope(
      canPop: !isLocked.value && customWidget.value == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _restoreSystemUI();
        } else if (isLocked.value) {
          // 1. If in focus mode, pressing back unlocks focus mode first
          isLocked.value = false;
        } else if (customWidget.value != null &&
            onHideCustomWidgetCallback.value != null) {
          // 2. If in HTML5 video fullscreen, pressing back exits fullscreen cleanly!
          onHideCustomWidgetCallback.value!();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
                        poster: poster ?? '',
                        episodeId: episodeId,
                        episodeNumber: episode.info?.episodeList
                                .firstWhere(
                                  (e) => e.episodeId == episodeId,
                                  orElse: () => episode.info!.episodeList.first,
                                )
                                .eps ??
                            0,
                      ),
                    );
              });
              return null;
            }, [episodeId]);

            final selectedServerId = useState<String?>(null);

            // Initial stream load
            useEffect(() {
              if (episode.defaultStreamingUrl != null) {
                controller.loadRequest(Uri.parse(episode.defaultStreamingUrl!));
              }
              return null;
            }, [episode.defaultStreamingUrl]);

            // ─── LOCK BUTTON WIDGET ──────────────────────────────
            Widget buildLockButton({required bool inFullscreen}) {
              return Positioned(
                top: inFullscreen
                    ? 16
                    : MediaQuery.of(context).padding.top + 4,
                right: 12,
                width: 44,
                height: 44,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      isLocked.value = !isLocked.value;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked.value
                            ? const Color(0x99000000)
                            : Colors.black54,
                        border: isLocked.value
                            ? Border.all(color: Colors.white30, width: 1)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isLocked.value
                            ? const Icon(
                                Icons.lock_rounded,
                                key: ValueKey('locked_icon'),
                                color: Colors.amberAccent,
                                size: 22,
                              )
                            : const Icon(
                                Icons.lock_open_rounded,
                                key: ValueKey('unlocked_icon'),
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // ─── TOP BAR OVERLAY ─────────────────────────────────
            Widget buildTopBar({required bool inFullscreen, VoidCallback? onBack}) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                top: isLocked.value ? -80 : 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: inFullscreen
                        ? 12
                        : MediaQuery.of(context).padding.top + 4,
                    left: 12,
                    right: 64, // Space for lock button
                    bottom: 8,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: onBack ??
                            () {
                              _restoreSystemUI();
                              context.pop();
                            },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              animeTitle ?? episode.title,
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (animeTitle != null)
                              Text(
                                episode.title,
                                style: AppTextStyles.caption
                                  .copyWith(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ─── 1. HTML5 FULLSCREEN CUSTOM VIEW OVERLAY ─────────
            if (customWidget.value != null) {
              return Stack(
                children: [
                  Positioned.fill(child: customWidget.value!),
                  // Touch barrier: absorbs all taps/drags so video controls don't pop up in Focus Mode!
                  if (isLocked.value)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        onDoubleTap: () {},
                        onVerticalDragUpdate: (_) {},
                        onHorizontalDragUpdate: (_) {},
                        child: const ColoredBox(color: Colors.transparent),
                      ),
                    ),
                  buildTopBar(
                    inFullscreen: true,
                    onBack: () {
                      if (onHideCustomWidgetCallback.value != null) {
                        onHideCustomWidgetCallback.value!();
                      }
                    },
                  ),
                  buildLockButton(inFullscreen: true),
                ],
              );
            }

            // ─── 2. EMBEDDED PLAYER WIDGET ───────────────────────
            final playerWidget = Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: WebViewWidget(controller: controller),
                  ),
                ),
                // Touch barrier: absorbs all taps/drags so video controls don't pop up in Focus Mode!
                if (isLocked.value)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      onDoubleTap: () {},
                      onVerticalDragUpdate: (_) {},
                      onHorizontalDragUpdate: (_) {},
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                buildTopBar(inFullscreen: isLandscape),
                buildLockButton(inFullscreen: isLandscape),
              ],
            );

            // In Landscape or Focus Mode in Portrait
            if (isLandscape || isLocked.value) {
              return playerWidget;
            }

            // Normal Portrait Mode Layout
            return SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: playerWidget,
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
                            ...episode.server!.qualities.map(
                              (q) => Padding(
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
                                        final isSelected =
                                            selectedServerId.value == s.serverId;
                                        return GestureDetector(
                                          onTap: () async {
                                            if (selectedServerId.value == s.serverId) return;
                                            selectedServerId.value = s.serverId;
                                            try {
                                              final url = await ref.read(
                                                streamingUrlProvider(s.serverId).future,
                                              );
                                              if (context.mounted && url.isNotEmpty) {
                                                controller.loadRequest(Uri.parse(url));
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Gagal memuat server'),
                                                  ),
                                                );
                                                selectedServerId.value = null;
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.accent
                                                  : AppColors.surface,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              s.title,
                                              style: AppTextStyles.label.copyWith(
                                                color: isSelected
                                                    ? AppColors.textPrimary
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => context.pushReplacement(
                                      '/player/${episode.prevEpisode!.episodeId}',
                                      extra: {
                                        'poster': poster,
                                        'animeTitle': animeTitle,
                                      },
                                    ),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => context.pushReplacement(
                                      '/player/${episode.nextEpisode!.episodeId}',
                                      extra: {
                                        'poster': poster,
                                        'animeTitle': animeTitle,
                                      },
                                    ),
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
      ),
    );
  }
}
