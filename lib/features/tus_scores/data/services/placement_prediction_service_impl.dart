import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';
import 'package:tus/features/tus_scores/domain/services/placement_prediction_service.dart';

class PlacementPredictionServiceImpl implements PlacementPredictionService {
  @override
  Future<List<PlacementPrediction>> predictPlacements({
    required int userScore,
    required int userRanking,
    required List<DepartmentPreference> preferences,
    required List<DepartmentScore> historicalScores,
    required List<Department> departments,
  }) async {
    final predictions = <PlacementPrediction>[];
    
    for (final department in departments) {
      final probability = await calculateSuccessProbability(
        departmentId: department.id,
        userScore: userScore,
        userRanking: userRanking,
        historicalScores: historicalScores,
      );
      
      predictions.add(PlacementPrediction(
        department: department,
        probability: probability,
        averageScore: department.minScore,
        minScore: department.minScore,
        maxScore: department.maxScore,
      ));
    }
    
    return predictions;
  }

  @override
  Future<List<Department>> getRecommendedDepartments({
    required int userScore,
    required int userRanking,
    required List<DepartmentPreference> preferences,
    required List<DepartmentScore> historicalScores,
    required List<Department> departments,
  }) async {
    final predictions = await predictPlacements(
      userScore: userScore,
      userRanking: userRanking,
      preferences: preferences,
      historicalScores: historicalScores,
      departments: departments,
    );
    
    predictions.sort((a, b) => b.probability.compareTo(a.probability));
    return predictions.map((p) => p.department).toList();
  }

  @override
  Future<double> calculateSuccessProbability({
    required String departmentId,
    required int userScore,
    required int userRanking,
    required List<DepartmentScore> historicalScores,
  }) async {
    final departmentScores = historicalScores
        .where((score) => score.departmentId == departmentId)
        .toList();
    
    if (departmentScores.isEmpty) {
      return 0.0;
    }
    
    final minScore = departmentScores.map((s) => s.score).reduce((a, b) => a < b ? a : b);
    final maxScore = departmentScores.map((s) => s.score).reduce((a, b) => a > b ? a : b);
    final minRanking = departmentScores.map((s) => s.ranking).reduce((a, b) => a < b ? a : b);
    final maxRanking = departmentScores.map((s) => s.ranking).reduce((a, b) => a > b ? a : b);
    
    final scoreProbability = (userScore - minScore) / (maxScore - minScore);
    final rankingProbability = (maxRanking - userRanking) / (maxRanking - minRanking);
    
    return (scoreProbability + rankingProbability) / 2;
  }
} 