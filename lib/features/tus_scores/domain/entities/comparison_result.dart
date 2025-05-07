import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';

part 'comparison_result.freezed.dart';
part 'comparison_result.g.dart';

@freezed
class ComparisonResult with _$ComparisonResult {
  const factory ComparisonResult({
    required List<Department> departments,
    required Map<String, double> scoreDifferences,
    required Map<String, double> quotaDifferences,
    required Map<String, double> successRateDifferences,
    required Map<String, List<double>> yearlyTrends,
    required Map<String, double> correlationScores,
  }) = _ComparisonResult;

  factory ComparisonResult.fromJson(Map<String, dynamic> json) =>
      _$ComparisonResultFromJson(json);
}

enum ComparisonType {
  score,
  quota,
  successRate,
  yearlyTrend,
  correlation
}

enum ChartType {
  bar,
  line,
  radar,
  scatter,
  bubble
} 