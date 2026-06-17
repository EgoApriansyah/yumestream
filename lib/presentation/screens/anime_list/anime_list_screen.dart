import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/anime_list_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

class AnimeListScreen extends ConsumerStatefulWidget {
  final String listType;

  const AnimeListScreen({
    super.key,
    required this.listType,
  });

  @override
  ConsumerState<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends ConsumerState<AnimeListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(animeListProvider(widget.listType).notifier).loadNext();
    }
  }

  String get _title {
    switch (widget.listType) {
      case 'ongoing':
        return 'Anime Ongoing';
      case 'complete':
        return 'Anime Baru Tamat';
      default:
        return 'Daftar Anime';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animeListProvider(widget.listType));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(_title, style: AppTextStyles.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.items.isEmpty
              ? AppErrorWidget(
                  message: state.error!,
                  onRetry: () => ref.read(animeListProvider(widget.listType).notifier).loadInitial(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(animeListProvider(widget.listType).notifier).loadInitial(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.items.length + (state.isFetchingNext ? 3 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final anime = state.items[index];
                      return AnimeCard(
                        anime: anime,
                        onTap: () => context.push('/detail/${anime.animeId}'),
                      );
                    },
                  ),
                ),
    );
  }
}
