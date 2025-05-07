import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tus/config/router/app_routes.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TUS Hazırlık Asistanı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuItem(
            context,
            'TUS Puanları',
            Icons.score,
            () => context.push(AppRoutes.tusScores),
          ),
          _buildMenuItem(
            context,
            'Tercih Simülasyonu',
            Icons.analytics,
            () => context.push(AppRoutes.preferenceSimulation),
          ),
          _buildMenuItem(
            context,
            'Tercih Listem',
            Icons.list,
            () => context.push(AppRoutes.preferenceList),
          ),
          _buildMenuItem(
            context,
            'Çalışma Programı',
            Icons.calendar_today,
            () {
              // TODO: Implement study schedule
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 