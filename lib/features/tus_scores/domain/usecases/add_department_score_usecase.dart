import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class AddDepartmentScoreParams {
  final String departmentId;
  final DepartmentScore score;

  const AddDepartmentScoreParams({
    required this.departmentId,
    required this.score,
  });
}

class AddDepartmentScoreUseCase implements UseCase<void, AddDepartmentScoreParams> {
  final TusScoresRepository repository;

  AddDepartmentScoreUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddDepartmentScoreParams params) async {
    return await repository.addDepartmentScore(params.departmentId, params.score);
  }
} 