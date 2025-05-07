import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/features/tus_scores/data/datasources/tus_scores_remote_data_source.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/entities/exam_period.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';
import 'package:tus/features/tus_scores/domain/entities/user.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/placement_prediction_service.dart';

class TusScoresRepositoryImpl implements TusScoresRepository {
  final TusScoresRemoteDataSource remoteDataSource;
  final PlacementPredictionService predictionService;
  final Database _database;
  final Connectivity _connectivity;

  TusScoresRepositoryImpl({
    required this.remoteDataSource,
    required this.predictionService,
    required Database database,
    Connectivity? connectivity,
  }) : _database = database,
       _connectivity = connectivity ?? Connectivity();

  Future<bool> get _isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<Either<Failure, List<Department>>> getDepartments(FilterParams filterParams) async {
    try {
      if (await _isConnected) {
        final departments = await remoteDataSource.getDepartments(filterParams);
        // Verileri yerel veritabanına kaydet
        await _saveDepartments(departments);
        return Right(departments);
      } else {
        // Offline modda yerel veritabanından oku
        final departments = await _getDepartmentsFromLocal(filterParams);
        return Right(departments);
      }
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _saveDepartments(List<Department> departments) async {
    final batch = _database.batch();
    for (final department in departments) {
      batch.insert(
        'departments',
        {
          'id': department.id,
          'name': department.name,
          'university': department.university,
          'faculty': department.faculty,
          'city': department.city,
          'quota': department.quota,
          'minScore': department.minScore,
          'maxScore': department.maxScore,
          'examPeriod': department.examPeriod.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Department>> _getDepartmentsFromLocal(FilterParams filterParams) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'departments',
      where: filterParams.city != null ? 'city = ?' : null,
      whereArgs: filterParams.city != null ? [filterParams.city] : null,
    );

    return List.generate(maps.length, (i) {
      return Department(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        university: maps[i]['university'] as String,
        faculty: maps[i]['faculty'] as String,
        city: maps[i]['city'] as String,
        quota: maps[i]['quota'] as int,
        minScore: maps[i]['minScore'] as double,
        maxScore: maps[i]['maxScore'] as double,
        examPeriod: DateTime.parse(maps[i]['examPeriod'] as String),
      );
    });
  }

  @override
  Future<Either<Failure, Department>> getDepartmentById(String id) async {
    try {
      final department = await remoteDataSource.getDepartmentById(id);
      return Right(department);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<DepartmentScore>>> getDepartmentScores(String departmentId) async {
    try {
      final scores = await remoteDataSource.getDepartmentScores(departmentId);
      return Right(scores);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ExamPeriod>>> getExamPeriods() async {
    try {
      final periods = await remoteDataSource.getExamPeriods();
      return Right(periods);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addDepartment(Department department) async {
    try {
      await remoteDataSource.addDepartment(department);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addDepartmentScore(String departmentId, DepartmentScore score) async {
    try {
      await remoteDataSource.addDepartmentScore(departmentId, score);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addExamPeriod(ExamPeriod examPeriod) async {
    try {
      await remoteDataSource.addExamPeriod(examPeriod);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    try {
      final user = await remoteDataSource.getUserById(id);
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserPreferences(String userId, List<DepartmentPreference> preferences) async {
    try {
      await remoteDataSource.updateUserPreferences(userId, preferences);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PlacementPrediction>>> getPlacementPredictions(String userId) async {
    try {
      final user = await remoteDataSource.getUserById(userId);
      final departments = await remoteDataSource.getDepartments(const FilterParams());
      final allScores = <DepartmentScore>[];
      
      for (final department in departments) {
        final scores = await remoteDataSource.getDepartmentScores(department.id);
        allScores.addAll(scores);
      }

      final predictions = await predictionService.predictPlacements(
        userScore: user.tusScore,
        userRanking: user.tusRanking,
        preferences: user.preferences,
        historicalScores: allScores,
        departments: departments,
      );

      return Right(predictions);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Department>>> getRecommendedDepartments(String userId) async {
    try {
      final user = await remoteDataSource.getUserById(userId);
      final departments = await remoteDataSource.getDepartments(const FilterParams());
      final allScores = <DepartmentScore>[];
      
      for (final department in departments) {
        final scores = await remoteDataSource.getDepartmentScores(department.id);
        allScores.addAll(scores);
      }

      final recommendations = await predictionService.getRecommendedDepartments(
        userScore: user.tusScore,
        userRanking: user.tusRanking,
        preferences: user.preferences,
        historicalScores: allScores,
        departments: departments,
      );

      return Right(recommendations);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserScore(String userId, int score, int ranking) async {
    try {
      await remoteDataSource.updateUserScore(userId, score, ranking);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
} 