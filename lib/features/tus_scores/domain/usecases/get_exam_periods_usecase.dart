import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/exam_period.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

import '../../../../core/usecase/no_params.dart';

class GetExamPeriodsUseCase implements UseCase<List<ExamPeriod>, NoParams> {
  final TusScoresRepository repository;

  GetExamPeriodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExamPeriod>>> call(NoParams params) async {
    return await repository.getExamPeriods();
  }
} 