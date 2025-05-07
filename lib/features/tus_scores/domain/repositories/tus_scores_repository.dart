import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/entities/exam_period.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';
import 'package:tus/features/tus_scores/domain/entities/user.dart';

abstract class TusScoresRepository {
  Future<Either<Failure, List<Department>>> getDepartments(FilterParams filterParams);
  Future<Either<Failure, Department>> getDepartmentById(String id);
  Future<Either<Failure, List<DepartmentScore>>> getDepartmentScores(String departmentId);
  Future<Either<Failure, List<ExamPeriod>>> getExamPeriods();
  Future<Either<Failure, void>> addDepartment(Department department);
  Future<Either<Failure, void>> addDepartmentScore(String departmentId, DepartmentScore score);
  Future<Either<Failure, void>> addExamPeriod(ExamPeriod examPeriod);
  Future<Either<Failure, User>> getUserById(String id);
  Future<Either<Failure, void>> updateUserPreferences(String userId, List<DepartmentPreference> preferences);
  Future<Either<Failure, List<PlacementPrediction>>> getPlacementPredictions(String userId);
  Future<Either<Failure, List<Department>>> getRecommendedDepartments(String userId);
  Future<Either<Failure, void>> updateUserScore(String userId, int score, int ranking);
} 