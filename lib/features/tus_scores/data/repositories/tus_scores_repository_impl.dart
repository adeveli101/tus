// TusScoresRemoteDataSource ile ilgili import ve tüm kullanımlar kaldırıldı.

import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tus/core/error/failures.dart';
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
  final PlacementPredictionService predictionService;
  final Database _database;
  final Connectivity _connectivity;

  TusScoresRepositoryImpl({
    required this.predictionService,
    required Database database,
    required Connectivity connectivity,
  })  : _database = database,
        _connectivity = connectivity;

  Future<bool> get _isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<Either<Failure, List<Department>>> getDepartments(FilterParams filterParams) async {
    try {
      if (await _isConnected) {
        final departments = await _getDepartmentsFromLocal(filterParams);
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
        score: (maps[i]['score'] as num).toDouble(),
        ranking: maps[i]['ranking'] as int,
        name: maps[i]['name'] as String,
        university: maps[i]['university'] as String,
        faculty: maps[i]['faculty'] as String,
        city: maps[i]['city'] as String,
        minScore: (maps[i]['min_score'] as num).toDouble(),
        maxScore: (maps[i]['max_score'] as num).toDouble(),
        examPeriod: maps[i]['exam_period'] as String,
        isFavorite: maps[i]['is_favorite'] == 1,
      );
    });
  }

  @override
  Future<Either<Failure, Department>> getDepartmentById(String id) async {
    try {
      final department = await _getDepartmentByIdFromLocal(id);
      return Right(department);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<Department> _getDepartmentByIdFromLocal(String id) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'departments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final department = maps.first;
      return Department(
        id: department['id'] as String,
        institution: department['institution'] as String,
        department: department['department'] as String,
        type: department['type'] as String,
        year: department['year'] as String,
        quota: department['quota'] as String,
        score: (department['score'] as num).toDouble(),
        ranking: department['ranking'] as int,
        name: department['name'] as String,
        university: department['university'] as String,
        faculty: department['faculty'] as String,
        city: department['city'] as String,
        minScore: (department['min_score'] as num).toDouble(),
        maxScore: (department['max_score'] as num).toDouble(),
        examPeriod: department['exam_period'] as String,
        isFavorite: department['is_favorite'] == 1,
      );
    } else {
      throw Exception('Department not found');
    }
  }

  @override
  Future<Either<Failure, List<DepartmentScore>>> getDepartmentScores(String departmentId) async {
    try {
      final scores = await _getDepartmentScoresFromLocal(departmentId);
      return Right(scores);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<List<DepartmentScore>> _getDepartmentScoresFromLocal(String departmentId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'department_scores',
      where: 'department_id = ?',
      whereArgs: [departmentId],
    );

    return List.generate(maps.length, (i) {
      return DepartmentScore(
        id: maps[i]['id'] as String,
        departmentId: maps[i]['department_id'] as String,
        score: (maps[i]['score'] as num).toInt(),
        ranking: maps[i]['ranking'] as int,
        examPeriod: DateTime.parse(maps[i]['exam_period'] as String),
      );
    });
  }

  @override
  Future<Either<Failure, List<ExamPeriod>>> getExamPeriods() async {
    try {
      final periods = await _getExamPeriodsFromLocal();
      return Right(periods);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<List<ExamPeriod>> _getExamPeriodsFromLocal() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'exam_periods',
    );

    return List.generate(maps.length, (i) {
      return ExamPeriod(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        startDate: DateTime.parse(maps[i]['start_date'] as String),
        endDate: DateTime.parse(maps[i]['end_date'] as String),
      );
    });
  }

  @override
  Future<Either<Failure, void>> addDepartment(Department department) async {
    try {
      await _addDepartmentToLocal(department);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _addDepartmentToLocal(Department department) async {
    await _database.insert(
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

  @override
  Future<Either<Failure, void>> addDepartmentScore(String departmentId, DepartmentScore score) async {
    try {
      await _addDepartmentScoreToLocal(departmentId, score);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _addDepartmentScoreToLocal(String departmentId, DepartmentScore score) async {
    await _database.insert(
      'department_scores',
      {
        'id': score.id,
        'department_id': departmentId,
        'score': score.score.toDouble(),
        'ranking': score.ranking,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Either<Failure, void>> addExamPeriod(ExamPeriod examPeriod) async {
    try {
      await _addExamPeriodToLocal(examPeriod);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _addExamPeriodToLocal(ExamPeriod examPeriod) async {
    await _database.insert(
      'exam_periods',
      {
        'id': examPeriod.id,
        'name': examPeriod.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    try {
      final user = await _getUserByIdFromLocal(id);
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<User> _getUserByIdFromLocal(String id) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final user = maps.first;
      return User(
        id: user['id'] as String,
        name: user['name'] as String,
        email: user['email'] as String,
        tusScore: (user['tus_score'] as num).toInt(),
        tusRanking: user['tus_ranking'] as int,
        preferences: [],
        createdAt: DateTime.parse(user['created_at'] as String),
      );
    } else {
      throw Exception('User not found');
    }
  }

  @override
  Future<Either<Failure, void>> updateUserPreferences(String userId, List<DepartmentPreference> preferences) async {
    try {
      await _updateUserPreferencesInLocal(userId, preferences);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _updateUserPreferencesInLocal(String userId, List<DepartmentPreference> preferences) async {
    // Implementation needed
  }

  @override
  Future<Either<Failure, List<PlacementPrediction>>> getPlacementPredictions(String userId) async {
    try {
      final user = await getUserById(userId);
      final departments = await getDepartments(const FilterParams());
      final allScores = <DepartmentScore>[];
      
      for (final department in departments.getOrElse(() => [])) {
        final scores = await getDepartmentScores(department.id);
        allScores.addAll(scores.getOrElse(() => []));
      }

      final predictions = await predictionService.predictPlacements(
        userScore: user.fold((l) => 0, (r) => r.tusScore),
        userRanking: user.fold((l) => 0, (r) => r.tusRanking),
        preferences: user.fold((l) => <DepartmentPreference>[], (r) => r.preferences),
        historicalScores: allScores,
        departments: departments.getOrElse(() => []),
      );

      return Right(predictions);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Department>>> getRecommendedDepartments(String userId) async {
    try {
      final user = await getUserById(userId);
      final departments = await getDepartments(const FilterParams());
      final allScores = <DepartmentScore>[];
      
      for (final department in departments.getOrElse(() => [])) {
        final scores = await getDepartmentScores(department.id);
        allScores.addAll(scores.getOrElse(() => []));
      }

      final recommendations = await predictionService.getRecommendedDepartments(
        userScore: user.fold((l) => 0, (r) => r.tusScore),
        userRanking: user.fold((l) => 0, (r) => r.tusRanking),
        preferences: user.fold((l) => <DepartmentPreference>[], (r) => r.preferences),
        historicalScores: allScores,
        departments: departments.getOrElse(() => []),
      );

      return Right(recommendations);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserScore(String userId, int score, int ranking) async {
    try {
      await _updateUserScoreInLocal(userId, score, ranking);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _updateUserScoreInLocal(String userId, int score, int ranking) async {
    // Implementation needed
  }

  Future<Either<Failure, void>> updateDepartment(Department department) async {
    try {
      await _updateDepartmentInLocal(department);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _updateDepartmentInLocal(Department department) async {
    await _database.update(
      'departments',
      {
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
      where: 'id = ?',
      whereArgs: [department.id],
    );
  }

  Future<Either<Failure, void>> deleteDepartment(String id) async {
    try {
      await _deleteDepartmentFromLocal(id);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _deleteDepartmentFromLocal(String id) async {
    await _database.delete(
      'departments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 