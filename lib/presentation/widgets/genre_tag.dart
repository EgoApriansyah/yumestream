import 'package:flutter/material.dart';

import 'package:anime/core/constants/app_colors.dart';
import 'package:anime/core/constants/app_text_styles.dart';
import 'package:anime/data/models/genre_model.dart';

class GenreTag extends StatelessWidget {
  final String title;
  final String genreId;
  final VoidCallback? onTap;

  const GenreTag({
    super.key,
    required this.title,
    required this.genreId,
    this.onTap,
  });

  factory GenreTag.fromModel({
    Key? key,
    required GenreModel genre,
    VoidCallback? onTap,
  }) {
    return GenreTag(
      key: key,
      title: genre.title ?? '',
      genreId: genre.genreId ?? '',
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: AppColors.accent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
