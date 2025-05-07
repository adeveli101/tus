import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/core/usecase/usecase.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';

class UpdateUserPreferencesUseCase implements UseCase<void, UpdatePreferencesParams> {
  final TusScoresRepository repository;

  UpdateUserPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePreferencesParams params) async {
    return await repository.updateUserPreferences(params.userId, params.preferences);
  }
}

class UpdatePreferencesParams {
  final String userId;
  final List<DepartmentPreference> preferences;

  UpdatePreferencesParams({
    required this.userId,
    required this.preferences,
  });
} 