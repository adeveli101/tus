import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';

part 'tus_scores_state.freezed.dart';
part 'tus_scores_state.g.dart';

@freezed
class TusScoresState with _$TusScoresState {
  const factory TusScoresState({
    @Default([]) List<DepartmentCategory> departments,
    @Default(FilterParams()) FilterParams filterParams,
    @Default(false) bool isLoading,
    String? error,
  }) = _TusScoresState;

  factory TusScoresState.fromJson(Map<String, dynamic> json) =>
      _$TusScoresStateFromJson(json);
} 