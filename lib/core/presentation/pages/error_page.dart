import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tus/config/router/app_routes.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';

class ErrorPage extends StatelessWidget {
  final String message;
  final String? code;

  const ErrorPage({
    super.key,
    required this.message,
    this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Bir hata oluştu',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (code != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Hata Kodu: $code',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 