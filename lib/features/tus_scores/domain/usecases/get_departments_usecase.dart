import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class GetDepartmentsUseCase implements UseCase<List<Department>, FilterParams> {
  final TusScoresRepository repository;

  GetDepartmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Department>>> call(FilterParams params) async {
    return await repository.getDepartments(params);
  }
} 