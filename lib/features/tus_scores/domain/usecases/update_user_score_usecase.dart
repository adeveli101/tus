import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class UpdateUserScoreUseCase implements UseCase<void, UpdateUserScoreParams> {
  final TusScoresRepository repository;

  UpdateUserScoreUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserScoreParams params) async {
    return await repository.updateUserScore(params.userId, params.score, params.ranking);
  }
}

class UpdateUserScoreParams {
  final String userId;
  final int score;
  final int ranking;

  UpdateUserScoreParams({
    required this.userId,
    required this.score,
    required this.ranking,
  });
} 