import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';

import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/preferences/presentation/pages/preference_list_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';
import '../../../features/tus_scores/presentation/pages/tus_scores_page.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onPageChanged;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onPageChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            label: 'TUS Puanları',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tercih Listem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
} 