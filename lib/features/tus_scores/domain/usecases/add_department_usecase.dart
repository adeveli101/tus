import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class AddDepartmentUseCase implements UseCase<void, Department> {
  final TusScoresRepository repository;

  AddDepartmentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Department params) async {
    return await repository.addDepartment(params);
  }
} 