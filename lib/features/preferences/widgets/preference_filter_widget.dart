import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';

class PreferenceFilterWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const PreferenceFilterWidget({
    super.key,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // TODO: Add filter widgets
          Text(
            'Filtreler',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
} 