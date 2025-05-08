import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/comparison_service.dart';

class ComparisonServiceImpl implements ComparisonService {
  final TusScoresRepository _repository;

  ComparisonServiceImpl(this._repository);

  @override
  Future<List<Department>> compareDepartmentsByScore(List<Department> departments) async {
    // Sort departments by minScore
    departments.sort((a, b) => a.minScore.compareTo(b.minScore));
    return departments;
  }

  @override
  Future<List<Department>> filterByPreferences(
    List<Department> departments,
    List<DepartmentPreference> preferences,
  ) async {
    final filteredDepartments = <Department>[];
    
    for (final department in departments) {
      final hasPreference = preferences.any((p) => p.departmentId == department.id);
      if (hasPreference) {
        filteredDepartments.add(department);
      }
    }
    
    return filteredDepartments;
  }

  @override
  Future<ComparisonResult> compareDepartmentsWithType(
    List<String> departmentIds,
    ComparisonType type,
  ) async {
    final departments = <Department>[];
    final scoreDifferences = <String, double>{};
    final quotaDifferences = <String, double>{};
    final successRateDifferences = <String, double>{};
    final yearlyTrends = <String, List<double>>{};
    final correlationScores = <String, double>{};

    // Get all departments
    for (final id in departmentIds) {
      final result = await _repository.getDepartmentById(id);
      result.fold(
        (failure) => null,
        (department) => departments.add(department),
      );
    }

    if (departments.isEmpty) {
      throw Exception('No departments found for comparison');
    }

    // Calculate differences based on comparison type
    switch (type) {
      case ComparisonType.score:
        _calculateScoreDifferences(departments, scoreDifferences);
        break;
      case ComparisonType.quota:
        _calculateQuotaDifferences(departments, quotaDifferences);
        break;
      case ComparisonType.successRate:
        await _calculateSuccessRateDifferences(
          departments,
          successRateDifferences,
        );
        break;
      case ComparisonType.yearlyTrend:
        await _calculateYearlyTrends(departments, yearlyTrends);
        break;
      case ComparisonType.correlation:
        await _calculateCorrelationScores(departments, correlationScores);
        break;
    }

    return ComparisonResult(
      departments: departments,
      scoreDifferences: scoreDifferences,
      quotaDifferences: quotaDifferences,
      successRateDifferences: successRateDifferences,
      yearlyTrends: yearlyTrends,
      correlationScores: correlationScores,
    );
  }

  void _calculateScoreDifferences(
    List<Department> departments,
    Map<String, double> differences,
  ) {
    final baseScore = departments.first.minScore;
    for (final department in departments) {
      differences[department.id] = department.minScore - baseScore;
    }
  }

  void _calculateQuotaDifferences(
    List<Department> departments,
    Map<String, double> differences,
  ) {
    final baseQuota = double.parse(departments.first.quota);
    for (final department in departments) {
      differences[department.id] = double.parse(department.quota) - baseQuota;
    }
  }

  Future<void> _calculateSuccessRateDifferences(
    List<Department> departments,
    Map<String, double> differences,
  ) async {
    for (final department in departments) {
      final scores = await _repository.getDepartmentScores(department.id);
      scores.fold(
        (failure) => null,
        (scores) {
          if (scores.isNotEmpty) {
            final successCount = scores.where((s) => s.score >= department.minScore).length;
            differences[department.id] = successCount / scores.length;
          }
        },
      );
    }
  }

  Future<void> _calculateYearlyTrends(
    List<Department> departments,
    Map<String, List<double>> trends,
  ) async {
    for (final department in departments) {
      final scores = await _repository.getDepartmentScores(department.id);
      scores.fold(
        (failure) => null,
        (scores) {
          final yearlyScores = <double>[];
          for (final score in scores) {
            yearlyScores.add(score.score.toDouble());
          }
          trends[department.id] = yearlyScores;
        },
      );
    }
  }

  Future<void> _calculateCorrelationScores(
    List<Department> departments,
    Map<String, double> correlations,
  ) async {
    for (final department in departments) {
      final scores = await _repository.getDepartmentScores(department.id);
      scores.fold(
        (failure) => null,
        (scores) {
          if (scores.length > 1) {
            final scoreValues = scores.map((s) => s.score.toDouble()).toList();
            correlations[department.id] = _calculateCorrelation(scoreValues);
          }
        },
      );
    }
  }

  double _calculateCorrelation(List<double> values) {
    if (values.length < 2) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.fold<double>(
      0,
      (sum, value) => sum + (value - mean) * (value - mean),
    ) / values.length;

    return variance;
  }
} 