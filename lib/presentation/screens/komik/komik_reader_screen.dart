import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/komik_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';

class ComicReaderScreen extends HookConsumerWidget {
  final String chapterSlug;
  final String? comicSlug;
  final String? comicTitle;
  final String? chapterNumber;

  const ComicReaderScreen({
    super.key,
    required this.chapterSlug,
    this.comicSlug,
    this.comicTitle,
    this.chapterNumber,
  });

  String _parseChapterNumberFromSlug(String slug, String defaultValue) {
    final regExp = RegExp(r'chapter-(\d+(?:\.\d+)?)');
    final match = regExp.firstMatch(slug.toLowerCase());
    if (match != null) {
      return 'Chapter ${match.group(1)}';
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(comicChapterImagesProvider(chapterSlug));
    final navAsync = ref.watch(comicChapterNavigationProvider(chapterSlug));
    final isLocked = useState<bool>(false);

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final topBarHeight = statusBarHeight + kToolbarHeight;

    // Manage Fullscreen/Immersive Mode when Locked (Focus Mode)
    useEffect(() {
      if (isLocked.value) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
      return () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      };
    }, [isLocked.value]);

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(comicChapterImagesProvider(chapterSlug)),
        ),
        data: (chapter) {
          // Mark chapter as read
          useEffect(() {
            Future.microtask(() {
              ref.read(comicReadChaptersProvider.notifier).markAsRead(
                    comicSlug: comicSlug ?? '',
                    chapterSlug: chapterSlug,
                  );
            });
            return null;
          }, [chapterSlug]);

          if (chapter.images.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada halaman gambar di chapter ini.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // Fallback navigation from chapter model
          final navData = navAsync.value ?? chapter.navigation;
          final prevSlug = navData?.prevSlug;
          final nextSlug = navData?.nextSlug;

          final hasPrev = prevSlug != null && prevSlug.isNotEmpty;
          final hasNext = nextSlug != null && nextSlug.isNotEmpty;

          return Stack(
            children: [
              // ─── 1. FULLSCREEN COMIC IMAGES STREAM ────────────────
              Positioned.fill(
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    top: isLocked.value ? 0 : topBarHeight,
                    bottom: isLocked.value ? 0 : ((hasPrev || hasNext) ? 90 : 24),
                  ),
                  itemCount: chapter.images.length,
                  itemBuilder: (context, index) {
                    final imgUrl = chapter.images[index];
                    return AppCachedImage(
                      imageUrl: imgUrl,
                      width: double.infinity,
                      borderRadius: 0,
                      fit: BoxFit.fitWidth,
                    );
                  },
                ),
              ),

              // ─── 2. SMOOTH ANIMATED TOP BAR OVERLAY ───────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                top: isLocked.value ? -topBarHeight : 0,
                left: 0,
                right: 0,
                height: topBarHeight,
                child: Container(
                  padding: EdgeInsets.only(top: statusBarHeight),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    border: Border(
                      bottom: BorderSide(color: Colors.white10, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comicTitle ?? chapter.mangaTitle ?? 'Baca Komik',
                              style: AppTextStyles.caption.copyWith(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chapterNumber ??
                                  chapter.chapterTitle ??
                                  _parseChapterNumberFromSlug(chapterSlug, 'Chapter'),
                              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Spacer width for the lock button so text doesn't overlap
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
              ),

              // ─── 3. SMOOTH ANIMATED BOTTOM CONTROLS OVERLAY ───────
              if (hasPrev || hasNext)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  bottom: isLocked.value ? -120 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      border: Border(
                        top: BorderSide(color: Colors.white10, width: 0.5),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.black45,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: hasPrev
                                  ? () {
                                      final numStr = _parseChapterNumberFromSlug(prevSlug, 'Sebelumnya');
                                      context.pushReplacement(
                                        '/komik/reader/$prevSlug',
                                        extra: {
                                          'comicSlug': comicSlug,
                                          'comicTitle': comicTitle ?? chapter.mangaTitle,
                                          'chapterNumber': numStr,
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
                                disabledBackgroundColor: Colors.black45,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: hasNext
                                  ? () {
                                      final numStr = _parseChapterNumberFromSlug(nextSlug, 'Selanjutnya');
                                      context.pushReplacement(
                                        '/komik/reader/$nextSlug',
                                        extra: {
                                          'comicSlug': comicSlug,
                                          'comicTitle': comicTitle ?? chapter.mangaTitle,
                                          'chapterNumber': numStr,
                                        },
                                      );
                                    }
                                  : null,
                              child: const Text('Selanjutnya'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ─── 4. PERMANENT FIXED LOCK BUTTON (ZERO SHIFT) ──────
              Positioned(
                top: statusBarHeight + ((kToolbarHeight - 44) / 2),
                right: 8,
                width: 44,
                height: 44,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      isLocked.value = !isLocked.value;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked.value
                            ? const Color(0x99000000)
                            : Colors.transparent,
                        border: isLocked.value
                            ? Border.all(color: Colors.white30, width: 1)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
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
              ),
            ],
          );
        },
      ),
    );
  }
}
