// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_cubit.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_state.dart';

class ScoreFilterWidget extends StatefulWidget {
  final Function(FilterParams) onFilterChanged;

  const ScoreFilterWidget({
    Key? key,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<ScoreFilterWidget> createState() => _ScoreFilterWidgetState();
}

class _ScoreFilterWidgetState extends State<ScoreFilterWidget> {
  String? selectedType;
  String? selectedYear;
  RangeValues scoreRange = const RangeValues(0, 100);
  RangeValues rankingRange = const RangeValues(0, 100000);
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Bölüm Ara...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.primaryLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tümü',
                  onSelected: (selected) {
                    setState(() {
                      selectedType = selected ? 'all' : null;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: 'Tıp',
                  onSelected: (selected) {
                    setState(() {
                      selectedType = selected ? 'medicine' : null;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: 'Diş Hekimliği',
                  onSelected: (selected) {
                    setState(() {
                      selectedType = selected ? 'dentistry' : null;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: 'Eczacılık',
                  onSelected: (selected) {
                    setState(() {
                      selectedType = selected ? 'pharmacy' : null;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildYearFilter(),
          const SizedBox(height: 16),
          _buildScoreRangeFilter(),
          const SizedBox(height: 16),
          _buildRankingRangeFilter(),
          const SizedBox(height: 16),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        selected: false,
        onSelected: onSelected,
        backgroundColor: AppColors.primaryLight,
        selectedColor: AppColors.primary,
        checkmarkColor: AppColors.textOnPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildYearFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Yıl', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedYear,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: const [
            DropdownMenuItem(value: '2024/2', child: Text('2024/2')),
            DropdownMenuItem(value: '2024/1', child: Text('2024/1')),
            DropdownMenuItem(value: '2023/2', child: Text('2023/2')),
          ],
          onChanged: (value) {
            setState(() {
              selectedYear = value;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildScoreRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Puan Aralığı', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        RangeSlider(
          values: scoreRange,
          min: 0,
          max: 100,
          divisions: 100,
          labels: RangeLabels(
            scoreRange.start.toStringAsFixed(1),
            scoreRange.end.toStringAsFixed(1),
          ),
          onChanged: (values) {
            setState(() {
              scoreRange = values;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildRankingRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sıralama Aralığı', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        RangeSlider(
          values: rankingRange,
          min: 0,
          max: 100000,
          divisions: 100,
          labels: RangeLabels(
            '${rankingRange.start.toInt()}',
            '${rankingRange.end.toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              rankingRange = values;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _applyFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Filtreleri Uygula',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    widget.onFilterChanged(
      FilterParams(
        type: selectedType,
        year: selectedYear,
        minScore: scoreRange.start,
        maxScore: scoreRange.end,
        minRanking: rankingRange.start.toInt(),
        maxRanking: rankingRange.end.toInt(),
        searchQuery: searchQuery,
      ),
    );
  }
} 