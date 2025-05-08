// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/features/tus_scores/domain/services/department_service.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_cubit.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_state.dart';
import 'package:tus/features/tus_scores/presentation/widgets/department_card.dart';
import 'package:tus/features/tus_scores/presentation/widgets/department_list_widget.dart';
import 'package:tus/features/tus_scores/presentation/widgets/score_filter_widget.dart';
import 'package:tus/core/presentation/widgets/app_bottom_nav.dart';

class TusScoresPage extends StatefulWidget {
  final Function(int) onPageChanged;
  
  const TusScoresPage({
    super.key,
    required this.onPageChanged,
  });

  @override
  State<TusScoresPage> createState() => _TusScoresPageState();
}

class _TusScoresPageState extends State<TusScoresPage> {
  late final DepartmentService _departmentService;

  @override
  void initState() {
    super.initState();
    _departmentService = context.read<DepartmentService>();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _departmentService.loadDepartments();
      if (mounted) {
        context.read<TusScoresCubit>().loadDepartments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading departments: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<TusScoresCubit, TusScoresState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDepartments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              ScoreFilterWidget(
                onFilterChanged: (params) {
                  context.read<TusScoresCubit>().updateFilterParams(params);
                },
              ),
              Expanded(
                child: DepartmentListWidget(
                  departments: state.departments,
                  onFavoriteToggle: (id) {
                    context.read<TusScoresCubit>().toggleFavorite(id);
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