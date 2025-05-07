import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/user.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class GetUserByIdUseCase implements UseCase<User, String> {
  final TusScoresRepository repository;

  GetUserByIdUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String userId) async {
    return await repository.getUserById(userId);
  }
} 