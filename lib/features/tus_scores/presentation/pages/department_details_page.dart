import 'package:flutter/material.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';

class DepartmentDetailsPage extends StatelessWidget {
  final Department department;

  const DepartmentDetailsPage({
    Key? key,
    required this.department,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(department.department),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Kurum Bilgileri',
              children: [
                _buildInfoRow('Kurum', department.institution),
                _buildInfoRow('Bölüm', department.department),
                _buildInfoRow('Tür', department.type),
                _buildInfoRow('Yıl', department.year),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Kontenjan ve Puan Bilgileri',
              children: [
                _buildInfoRow('Kontenjan/Yer', department.quota),
                _buildInfoRow('Taban Puan', department.score.toString()),
                _buildInfoRow('Sıralama', department.ranking.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // ignore: prefer_const_constructors
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 