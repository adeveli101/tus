import 'package:freezed_annotation/freezed_annotation.dart';

part 'department_statistics.freezed.dart';
part 'department_statistics.g.dart';

@freezed
class DepartmentStatistics with _$DepartmentStatistics {
  const factory DepartmentStatistics({
    required String departmentId,
    required int totalApplications,
    required double successRate,
    required List<YearlyTrend> yearlyTrends,
    required Map<String, double> correlationFactors,
    required DateTime lastUpdated,
  }) = _DepartmentStatistics;

  factory DepartmentStatistics.fromJson(Map<String, dynamic> json) =>
      _$DepartmentStatisticsFromJson(json);
}

@freezed
class YearlyTrend with _$YearlyTrend {
  const factory YearlyTrend({
    required int year,
    required double averageScore,
    required int totalApplications,
    required int successfulApplications,
    required double successRate,
  }) = _YearlyTrend;

  factory YearlyTrend.fromJson(Map<String, dynamic> json) =>
      _$YearlyTrendFromJson(json);
} 