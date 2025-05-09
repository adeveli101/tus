import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';

class PreferenceListWidget extends StatelessWidget {
  final List<dynamic> preferences;
  final Function(dynamic) onPreferenceTap;
  final VoidCallback onResetFilters;

  const PreferenceListWidget({
    super.key,
    required this.preferences,
    required this.onPreferenceTap,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (preferences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ignore: prefer_const_constructors
            Icon(Icons.search_off, color: AppColors.primaryDark, size: 64),
            const SizedBox(height: 16),
            Text(
              'Aramanıza uygun sonuç bulunamadı',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Filtreleri sıfırlayarak veya yeni bir arama yaparak tekrar deneyebilirsiniz.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onResetFilters,
              child: const Text('Filtreleri Sıfırla'),
            ),
          ],
        ),
      );
    }
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