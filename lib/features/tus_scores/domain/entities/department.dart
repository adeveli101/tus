import 'package:freezed_annotation/freezed_annotation.dart';

part 'department.freezed.dart';
part 'department.g.dart';

@freezed
class Department with _$Department {
  const factory Department({
    required String id,
    required String institution,
    required String department,
    required String type,
    required String year,
    required String quota,
    required double score,
    required int ranking,
    required String name,
    required String university,
    required String faculty,
    required String city,
    required double minScore,
    required double maxScore,
    required String examPeriod,
    @Default(false) bool isFavorite,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);
} 