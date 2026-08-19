import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/schedule_model.dart';
import '../../providers/home_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_card.dart';

class ScheduleScreen extends HookConsumerWidget {
  const ScheduleScreen({super.key});

  static const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Tayang', style: AppTextStyles.titleLarge),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _days.map((day) {
                final isSelected = day == selectedDay;
                return GestureDetector(
                  onTap: () => ref.read(selectedDayProvider.notifier).state = day,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      day,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: scheduleAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 10,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, __) => Row(
                  children: [
                    const ShimmerCard(width: 80, height: 110),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerCard(width: double.infinity, height: 16),
                          SizedBox(height: 8),
                          ShimmerCard(width: 100, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              error: (err, _) => AppErrorWidget(
                message: err.toString(),
                onRetry: () => ref.invalidate(scheduleProvider),
              ),
              data: (scheduleData) {
                final daySchedule = scheduleData.firstWhere(
                  (s) => s.day == selectedDay,
                  orElse: () => scheduleData.first,
                );

                if (daySchedule.items.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada tayangan atau update di hari ini',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: daySchedule.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final item = daySchedule.items[index];
                    return GestureDetector(
                      onTap: () {
                        if (item.type == UnifiedScheduleType.anime) {
                          context.push('/detail/${item.id}');
                        } else if (item.type == UnifiedScheduleType.dramabox) {
                          context.push('/dramabox/detail/${item.id}');
                        } else if (item.type == UnifiedScheduleType.komik) {
                          context.push('/komik/detail/${item.id}');
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppCachedImage(
                            imageUrl: item.imageUrl,
                            width: 80,
                            height: 110,
                            borderRadius: 8,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTextStyles.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: item.type == UnifiedScheduleType.anime
                                            ? AppColors.tagBackground
                                            : item.type == UnifiedScheduleType.dramabox
                                                ? Colors.red.withOpacity(0.15)
                                                : Colors.green.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.typeLabel,
                                        style: AppTextStyles.caption.copyWith(
                                          color: item.type == UnifiedScheduleType.anime
                                              ? AppColors.accent
                                              : item.type == UnifiedScheduleType.dramabox
                                                  ? Colors.redAccent
                                                  : Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.subtitle,
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }
}
