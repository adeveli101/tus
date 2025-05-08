import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/features/preferences/cubit/preference_list_cubit.dart';
import 'package:tus/features/preferences/cubit/preference_list_state.dart';
import 'package:tus/features/preferences/widgets/preference_filter_widget.dart';
import 'package:tus/features/preferences/widgets/preference_list_widget.dart';

class PreferenceListPage extends StatelessWidget {
  final Function(int) onPageChanged;
  
  const PreferenceListPage({
    super.key,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<PreferenceListCubit, PreferenceListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error!,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PreferenceListCubit>().loadPreferences();
                    },
                    child: const Text(
                      'Tekrar Dene',
                      style: AppTextStyles.button,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              PreferenceFilterWidget(
                onFilterChanged: (params) {
                  context.read<PreferenceListCubit>().updateFilterParams(params);
                },
              ),
              Expanded(
                child: PreferenceListWidget(
                  preferences: state.preferences,
                  onPreferenceTap: (preference) {
                    // TODO: Navigate to preference details
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 