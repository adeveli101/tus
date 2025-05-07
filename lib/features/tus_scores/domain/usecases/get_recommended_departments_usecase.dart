import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class GetRecommendedDepartmentsUseCase implements UseCase<List<Department>, String> {
  final TusScoresRepository repository;

  GetRecommendedDepartmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Department>>> call(String userId) async {
    return await repository.getRecommendedDepartments(userId);
  }
} 