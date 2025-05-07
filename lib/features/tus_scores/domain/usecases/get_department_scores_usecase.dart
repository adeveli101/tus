import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class GetDepartmentScoresUseCase implements UseCase<List<DepartmentScore>, String> {
  final TusScoresRepository repository;

  GetDepartmentScoresUseCase(this.repository);

  @override
  Future<Either<Failure, List<DepartmentScore>>> call(String departmentId) async {
    return await repository.getDepartmentScores(departmentId);
  }
} 