// ignore_for_file: unused_import

import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

enum ComparisonType {
  score,
  quota,
  successRate,
  yearlyTrend,
  correlation,
}

class ComparisonResult {
  final List<Department> departments;
  final Map<String, double> scoreDifferences;
  final Map<String, double> quotaDifferences;
  final Map<String, double> successRateDifferences;
  final Map<String, List<double>> yearlyTrends;
  final Map<String, double> correlationScores;

  ComparisonResult({
    required this.departments,
    required this.scoreDifferences,
    required this.quotaDifferences,
    required this.successRateDifferences,
    required this.yearlyTrends,
    required this.correlationScores,
  });
}

abstract class ComparisonService {
  Future<List<Department>> compareDepartmentsByScore(List<Department> departments);
  Future<List<Department>> filterByPreferences(List<Department> departments, List<DepartmentPreference> preferences);
  Future<ComparisonResult> compareDepartmentsWithType(
    List<String> departmentIds,
    ComparisonType type,
  );
} 