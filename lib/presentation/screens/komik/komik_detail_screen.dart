import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/komik_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';

class ComicDetailScreen extends ConsumerWidget {
  final String slug;

  const ComicDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(comicDetailProvider(slug));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Scaffold(
          appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
          body: AppErrorWidget(
            message: err.toString(),
            onRetry: () => ref.invalidate(comicDetailProvider(slug)),
          ),
        ),
        data: (comic) {
          return CustomScrollView(
            slivers: [
              // ─── APP BAR WITH HEADER ──────────────────────────────
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
                        imageUrl: comic.coverImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppCachedImage(
                              imageUrl: comic.coverImageUrl,
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
                                    comic.title,
                                    style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (comic.type != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.tagBackground,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            comic.type!.toUpperCase(),
                                            style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (comic.status != null)
                                        Text(
                                          comic.status!,
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                        ),
                                    ],
                                  ),
                                  if (comic.author != null && comic.author!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Author: ${comic.author}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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

              // ─── DESCRIPTION & GENRES ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Synopsis
                      Text('Sinopsis', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        comic.description.isNotEmpty
                            ? comic.description
                            : 'Tidak ada sinopsis untuk komik ini.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      ),
                      
                      const SizedBox(height: 20),

                      // Genres
                      if (comic.genres.isNotEmpty) ...[
                        Text('Genre', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: comic.genres.map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                genre,
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Chapters Title
                      Text('Daftar Chapter', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ─── CHAPTERS LIST ─────────────────────────────────────
              if (comic.chapters.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('Tidak ada chapter yang tersedia', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ch = comic.chapters[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider, width: 0.5),
                        ),
                        child: ListTile(
                          onTap: () {
                            context.push(
                              '/komik/reader/${ch.chapterId}',
                              extra: {
                                'comicTitle': comic.title,
                                'chapterNumber': ch.chapterNumber,
                              },
                            );
                          },
                          title: Text(
                            ch.chapterTitle ?? 'Chapter ${ch.chapterNumber}',
                            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                          subtitle: ch.createdAt != null && ch.createdAt!.isNotEmpty
                              ? Text(
                                  ch.createdAt!.split('T')[0],
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                )
                              : null,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                        ),
                      );
                    },
                    childCount: comic.chapters.length,
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
