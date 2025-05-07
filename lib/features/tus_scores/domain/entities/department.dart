import 'package:freezed_annotation/freezed_annotation.dart';

part 'department.freezed.dart';
part 'department.g.dart';

@freezed
class Department with _$Department {
  const factory Department({
    required String id,
    required String name,
    required String university,
    required String faculty,
    required String city,
    required int quota,
    required double minScore,
    required double maxScore,
    required DateTime examPeriod,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);
} 