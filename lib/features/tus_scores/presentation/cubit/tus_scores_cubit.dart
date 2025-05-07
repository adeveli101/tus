import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_departments_usecase.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_state.dart';

class TusScoresCubit extends Cubit<TusScoresState> {
  final GetDepartmentsUseCase getDepartmentsUseCase;

  TusScoresCubit({
    required this.getDepartmentsUseCase,
  }) : super(const TusScoresState());

  Future<void> loadDepartments() async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await getDepartmentsUseCase(state.filterParams);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (departments) => emit(state.copyWith(
        isLoading: false,
        departments: departments,
      )),
    );
  }

  void updateFilters(FilterParams filterParams) {
    emit(state.copyWith(filterParams: filterParams));
    loadDepartments();
  }

  void clearFilters() {
    emit(state.copyWith(filterParams: const FilterParams()));
    loadDepartments();
  }
} 