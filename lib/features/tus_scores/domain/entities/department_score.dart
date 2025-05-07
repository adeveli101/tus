import 'package:freezed_annotation/freezed_annotation.dart';

part 'department_score.freezed.dart';
part 'department_score.g.dart';

@freezed
class DepartmentScore with _$DepartmentScore {
  const factory DepartmentScore({
    required String id,
    required String departmentId,
    required int score,
    required int ranking,
    required DateTime examPeriod,
  }) = _DepartmentScore;

  factory DepartmentScore.fromJson(Map<String, dynamic> json) =>
      _$DepartmentScoreFromJson(json);
} 