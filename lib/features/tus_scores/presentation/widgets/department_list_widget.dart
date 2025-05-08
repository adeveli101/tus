import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';
import 'package:tus/features/tus_scores/presentation/widgets/department_card.dart';

class DepartmentListWidget extends StatelessWidget {
  final List<DepartmentCategory> departments;
  final Function(String) onFavoriteToggle;

  const DepartmentListWidget({
    super.key,
    required this.departments,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        final category = departments[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category.name,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...category.departments.map((department) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DepartmentCard(
                    department: department,
                    onFavoriteToggle: onFavoriteToggle,
                  ),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
} 