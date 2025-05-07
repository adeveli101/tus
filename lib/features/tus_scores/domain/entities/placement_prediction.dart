import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';

part 'placement_prediction.freezed.dart';
part 'placement_prediction.g.dart';

@freezed
class PlacementPrediction with _$PlacementPrediction {
  const factory PlacementPrediction({
    required Department department,
    required double probability,
    required double averageScore,
    required double minScore,
    required double maxScore,
  }) = _PlacementPrediction;

  factory PlacementPrediction.fromJson(Map<String, dynamic> json) =>
      _$PlacementPredictionFromJson(json);
} 