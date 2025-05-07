import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class GetPlacementPredictionsUseCase implements UseCase<List<PlacementPrediction>, String> {
  final TusScoresRepository repository;

  GetPlacementPredictionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PlacementPrediction>>> call(String userId) async {
    return await repository.getPlacementPredictions(userId);
  }
} 