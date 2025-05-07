import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/exam_period.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class AddExamPeriodUseCase implements UseCase<void, ExamPeriod> {
  final TusScoresRepository repository;

  AddExamPeriodUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ExamPeriod params) async {
    return await repository.addExamPeriod(params);
  }
} 