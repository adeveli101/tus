import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';

abstract class PredictionService {
  Future<List<PlacementPrediction>> predictPlacements(String userId);
  Future<List<Department>> getRecommendedDepartments(String userId);
  Future<double> calculateSuccessProbability(String departmentId, int userScore);
} 