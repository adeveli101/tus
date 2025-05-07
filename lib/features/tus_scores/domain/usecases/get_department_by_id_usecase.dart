import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class GetDepartmentByIdUseCase implements UseCase<Department, String> {
  final TusScoresRepository repository;

  GetDepartmentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Department>> call(String params) async {
    return await repository.getDepartmentById(params);
  }
} 