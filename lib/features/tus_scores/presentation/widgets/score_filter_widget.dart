// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_cubit.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_state.dart';

class ScoreFilterWidget extends StatelessWidget {
  const ScoreFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TusScoresCubit, TusScoresState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtreler',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                context,
                'Sınav Dönemi',
                state.filterParams.examPeriod,
                (value) {
                  context.read<TusScoresCubit>().updateFilters(
                        state.filterParams.copyWith(
                          examPeriod: value,
                        ),
                      );
                },
              ),
              const SizedBox(height: 8),
              _buildFilterField(
                context,
                'Şehir',
                state.filterParams.city,
                (value) {
                  context.read<TusScoresCubit>().updateFilters(
                        state.filterParams.copyWith(
                          city: value,
                        ),
                      );
                },
              ),
              const SizedBox(height: 8),
              _buildFilterField(
                context,
                'Üniversite',
                state.filterParams.university,
                (value) {
                  context.read<TusScoresCubit>().updateFilters(
                        state.filterParams.copyWith(
                          university: value,
                        ),
                      );
                },
              ),
              const SizedBox(height: 8),
              _buildFilterField(
                context,
                'Fakülte',
                state.filterParams.faculty,
                (value) {
                  context.read<TusScoresCubit>().updateFilters(
                        state.filterParams.copyWith(
                          faculty: value,
                        ),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? value,
    ValueChanged<DateTime?> onChanged,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null ? dateFormat.format(value) : 'Seçiniz',
        ),
      ),
    );
  }

  Widget _buildFilterField(
    BuildContext context,
    String label,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value),
      onChanged: onChanged,
    );
  }
} 