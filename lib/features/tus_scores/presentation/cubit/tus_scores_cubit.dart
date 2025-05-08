import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/services/department_service.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_state.dart';

class TusScoresCubit extends Cubit<TusScoresState> {
  final DepartmentService _departmentService;

  TusScoresCubit(this._departmentService) : super(const TusScoresState());

  Future<void> loadDepartments() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final departments = await _departmentService.loadDepartments();
      emit(state.copyWith(
        departments: departments,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void updateFilterParams(FilterParams params) {
    emit(state.copyWith(filterParams: params));
  }

  void clearFilters() {
    emit(state.copyWith(filterParams: const FilterParams()));
  }

  void toggleFavorite(String departmentId) {
    final updatedDepartments = state.departments.map((category) {
      if (category.departments.any((d) => d.id == departmentId)) {
        return category.copyWith(
          departments: category.departments.map((dept) {
            if (dept.id == departmentId) {
              return dept.copyWith(isFavorite: !dept.isFavorite);
            }
            return dept;
          }).toList(),
        );
      }
      return category;
    }).toList();

    emit(state.copyWith(departments: updatedDepartments));
  }
} 