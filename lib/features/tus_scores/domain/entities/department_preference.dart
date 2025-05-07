import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'department_preference.freezed.dart';
part 'department_preference.g.dart';

@freezed
class DepartmentPreference with _$DepartmentPreference {
  const factory DepartmentPreference({
    required String id,
    required String departmentId,
    required int preferenceOrder,
    required DateTime createdAt,
  }) = _DepartmentPreference;

  factory DepartmentPreference.fromJson(Map<String, dynamic> json) =>
      _$DepartmentPreferenceFromJson(json);
}

extension DepartmentPreferenceFirestore on DepartmentPreference {
  Map<String, dynamic> toFirestore() {
    return {
      'departmentId': departmentId,
      'preferenceOrder': preferenceOrder,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 