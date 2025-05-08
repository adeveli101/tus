import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';

part 'department_category.freezed.dart';
part 'department_category.g.dart';

@freezed
class DepartmentCategory with _$DepartmentCategory {
  const factory DepartmentCategory({
    required String id,
    required String name,
    required List<Department> departments,
  }) = _DepartmentCategory;

  factory DepartmentCategory.fromJson(Map<String, dynamic> json) =>
      _$DepartmentCategoryFromJson(json);
} 