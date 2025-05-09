import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';

class PreferenceSimulationResultsPage extends StatelessWidget {
  const PreferenceSimulationResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real simulation result check
    const bool hasResults = true; // Set to false to simulate empty/error state
    const String? errorMessage = null; // Set to a string to simulate error

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          title: Text(
            'Simülasyon Sonuçları',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 64),
              const SizedBox(height: 16),
              Text(
                'Bir hata oluştu',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Simülasyona Dön'),
              ),
            ],
          ),
        ),
      );
    }

    // ignore: dead_code
    if (!hasResults) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          title: Text(
            'Simülasyon Sonuçları',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryDark, size: 64),
              const SizedBox(height: 16),
              Text(
                'Sonuç bulunamadı',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Girdiğiniz puan ve filtrelerle eşleşen bir yerleşme tahmini bulunamadı. Farklı bir puan veya filtreyle tekrar deneyebilirsiniz.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Simülasyona Dön'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        title: Text(
          'Simülasyon Sonuçları',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kişisel Yerleşme İhtimali
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kişisel Yerleşme İhtimali',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPlacementProbabilityItem(
                      'Kardiyoloji - İstanbul Üniversitesi',
                      85,
                      'Yüksek',
                    ),
                    _buildPlacementProbabilityItem(
                      'Radyoloji - Ankara Üniversitesi',
                      65,
                      'Orta',
                    ),
                    _buildPlacementProbabilityItem(
                      'Dahiliye - Hacettepe Üniversitesi',
                      45,
                      'Düşük',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kadroları Tercih Eden Diğer Kullanıcılar
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kadroları Tercih Eden Diğer Kullanıcılar',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOtherUsersPreferenceItem(
                      'Kardiyoloji - İstanbul Üniversitesi',
                      150,
                      '1000-2000',
                    ),
                    _buildOtherUsersPreferenceItem(
                      'Radyoloji - Ankara Üniversitesi',
                      120,
                      '2000-3000',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // İstatistikler ve Grafikler
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İstatistikler ve Grafikler',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          'Grafikler burada gösterilecek',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Detaylı Kadro Bilgisi
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detaylı Kadro Bilgisi',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailedPositionInfo(
                      'Kardiyoloji - İstanbul Üniversitesi',
                      'Kontenjan: 5\nGeçmiş Yıl Taban Puanı: 85.5\nGeçmiş Yıl Taban Sıralaması: 1500',
                    ),
                    _buildDetailedPositionInfo(
                      'Radyoloji - Ankara Üniversitesi',
                      'Kontenjan: 3\nGeçmiş Yıl Taban Puanı: 82.3\nGeçmiş Yıl Taban Sıralaması: 2500',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacementProbabilityItem(
    String position,
    int probability,
    String level,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              position,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 24,
            decoration: BoxDecoration(
              color: _getProbabilityColor(level),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$probability%',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherUsersPreferenceItem(
    String position,
    int userCount,
    String rankRange,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              position,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$userCount kullanıcı',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Sıralama: $rankRange',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPositionInfo(
    String position,
    String details,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            position,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProbabilityColor(String level) {
    switch (level.toLowerCase()) {
      case 'yüksek':
        return AppColors.success;
      case 'orta':
        return AppColors.warning;
      case 'düşük':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
} 