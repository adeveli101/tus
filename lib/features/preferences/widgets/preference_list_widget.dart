import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';

class PreferenceListWidget extends StatelessWidget {
  final List<dynamic> preferences;
  final Function(dynamic) onPreferenceTap;

  const PreferenceListWidget({
    super.key,
    required this.preferences,
    required this.onPreferenceTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: preferences.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            'Tercih ${index + 1}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          onTap: () => onPreferenceTap(preferences[index]),
        );
      },
    );
  }
} 