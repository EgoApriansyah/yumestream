import 'package:flutter/material.dart';

import 'package:anime/core/constants/app_colors.dart';
import 'package:anime/core/constants/app_text_styles.dart';

class EpisodeChip extends StatelessWidget {
  final int episodeNumber;
  final bool isSelected;
  final VoidCallback? onTap;

  const EpisodeChip({
    super.key,
    required this.episodeNumber,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.elevated,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$episodeNumber',
          style: AppTextStyles.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
