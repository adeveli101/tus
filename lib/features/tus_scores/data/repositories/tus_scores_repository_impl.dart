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
import 'package:cloud_firestore/cloud_firestore.dart';

class TusScoresRepositoryImpl implements TusScoresRepository {
  final TusScoresRemoteDataSource remoteDataSource;
  final PlacementPredictionService predictionService;
  final Database _database;
  final Connectivity _connectivity;
  final FirebaseFirestore _firestore;

  TusScoresRepositoryImpl({
    required this.remoteDataSource,
    required this.predictionService,
    required Database database,
    required Connectivity connectivity,
    required FirebaseFirestore firestore,
  })  : _database = database,
        _connectivity = connectivity,
        _firestore = firestore;

  Future<bool> get _isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<Either<Failure, List<Department>>> getDepartments(FilterParams filterParams) async {
    try {
      if (await _isConnected) {
        final departments = await remoteDataSource.getDepartments(filterParams);
        await _saveDepartments(departments);
        return Right(departments);
      } else {
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
          'institution': department.institution,
          'department': department.department,
          'type': department.type,
          'year': department.year,
          'quota': department.quota,
          'score': department.score.toDouble(),
          'ranking': department.ranking,
          'name': department.name,
          'university': department.university,
          'faculty': department.faculty,
          'city': department.city,
          'min_score': department.minScore,
          'max_score': department.maxScore,
          'exam_period': department.examPeriod,
          'is_favorite': department.isFavorite ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Department>> _getDepartmentsFromLocal(FilterParams filterParams) async {
    String? whereClause;
    List<dynamic>? whereArgs;

    if (filterParams.city != null) {
      whereClause = 'city = ?';
      whereArgs = [filterParams.city];
    }
    if (filterParams.university != null) {
      whereClause = whereClause != null ? '$whereClause AND university = ?' : 'university = ?';
      whereArgs = whereArgs != null ? [...whereArgs, filterParams.university] : [filterParams.university];
    }
    if (filterParams.faculty != null) {
      whereClause = whereClause != null ? '$whereClause AND faculty = ?' : 'faculty = ?';
      whereArgs = whereArgs != null ? [...whereArgs, filterParams.faculty] : [filterParams.faculty];
    }
    if (filterParams.examPeriod != null) {
      whereClause = whereClause != null ? '$whereClause AND exam_period = ?' : 'exam_period = ?';
      whereArgs = whereArgs != null ? [...whereArgs, filterParams.examPeriod] : [filterParams.examPeriod];
    }

    final List<Map<String, dynamic>> maps = await _database.query(
      'departments',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Department(
        id: maps[i]['id'] as String,
        institution: maps[i]['institution'] as String,
        department: maps[i]['department'] as String,
        type: maps[i]['type'] as String,
        year: maps[i]['year'] as String,
        quota: maps[i]['quota'] as String,
        score: (maps[i]['score'] as double).toDouble(),
        ranking: maps[i]['ranking'] as int,
        name: maps[i]['name'] as String,
        university: maps[i]['university'] as String,
        faculty: maps[i]['faculty'] as String,
        city: maps[i]['city'] as String,
        minScore: maps[i]['min_score'] as double,
        maxScore: maps[i]['max_score'] as double,
        examPeriod: maps[i]['exam_period'] as String,
        isFavorite: maps[i]['is_favorite'] == 1,
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
      await _firestore.collection('departments').doc(department.id).set({
        'institution': department.institution,
        'department': department.department,
        'type': department.type,
        'year': department.year,
        'quota': department.quota,
        'score': department.score,
        'ranking': department.ranking,
        'is_favorite': department.isFavorite,
      });
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

  Future<Either<Failure, void>> updateDepartment(Department department) async {
    try {
      await _firestore.collection('departments').doc(department.id).update({
        'institution': department.institution,
        'department': department.department,
        'type': department.type,
        'year': department.year,
        'quota': department.quota,
        'score': department.score.toDouble(),
        'ranking': department.ranking,
        'name': department.name,
        'university': department.university,
        'faculty': department.faculty,
        'city': department.city,
        'min_score': department.minScore,
        'max_score': department.maxScore,
        'exam_period': department.examPeriod,
        'is_favorite': department.isFavorite,
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<Either<Failure, void>> deleteDepartment(String id) async {
    try {
      await _firestore.collection('departments').doc(id).delete();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
} 