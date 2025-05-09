import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/core/presentation/widgets/app_bottom_nav.dart';

class SettingsPage extends StatelessWidget {
  final Function(int) onPageChanged;
  
  const SettingsPage({
    super.key,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingItem(
            title: 'Tema',
            subtitle: 'Sistem',
            icon: Icons.palette,
            onTap: () {
              // TODO: Implement theme settings
            },
          ),
          _buildSettingItem(
            title: 'Bildirimler',
            subtitle: 'Açık',
            icon: Icons.notifications,
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          _buildSettingItem(
            title: 'Dil',
            subtitle: 'Türkçe',
            icon: Icons.language,
            onTap: () {
              // TODO: Implement language settings
            },
          ),
          _buildSettingItem(
            title: 'Hakkında',
            icon: Icons.info,
            onTap: () {
              // TODO: Implement about page
            },
          ),
        ],
      ),
      // bottomNavigationBar: AppBottomNav(
      //   currentIndex: 3,
      //   onPageChanged: onPageChanged,
      // ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.textPrimary,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
} 