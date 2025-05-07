import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';

abstract class PlacementPredictionService {
  Future<List<PlacementPrediction>> predictPlacements({
    required int userScore,
    required int userRanking,
    required List<DepartmentPreference> preferences,
    required List<DepartmentScore> historicalScores,
    required List<Department> departments,
  });

  Future<List<Department>> getRecommendedDepartments({
    required int userScore,
    required int userRanking,
    required List<DepartmentPreference> preferences,
    required List<DepartmentScore> historicalScores,
    required List<Department> departments,
  });

  Future<double> calculateSuccessProbability({
    required String departmentId,
    required int userScore,
    required int userRanking,
    required List<DepartmentScore> historicalScores,
  });
} 