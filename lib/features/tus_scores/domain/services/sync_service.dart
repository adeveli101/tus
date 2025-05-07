import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/comparison_service.dart';

import '../entities/filter_params.dart';

abstract class SyncService {
  Future<void> syncData();
  Future<void> syncDepartments();
  Future<void> syncDepartmentScores();
  Future<void> syncUserPreferences();
}

class SyncServiceImpl implements SyncService {
  final TusScoresRepository _repository;
  final Database _database;
  final Connectivity _connectivity;

  SyncServiceImpl(this._repository, this._database, this._connectivity);

  @override
  Future<void> syncData() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection available');
    }

    // Sync departments
    await syncDepartments();
    
    // Sync department scores
    await syncDepartmentScores();
    
    // Optimize storage
    await optimizeStorage();
  }

  @override
  Future<void> syncDepartments() async {
    final departments = await _repository.getDepartments(const FilterParams());
    departments.fold(
      (failure) => throw Exception('Failed to sync departments'),
      (departments) async {
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
              'lastSynced': DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit();
      },
    );
  }

  @override
  Future<void> syncDepartmentScores() async {
    final departments = await _getLocalDepartments();
    for (final department in departments) {
      final scores = await _repository.getDepartmentScores(department.id);
      scores.fold(
        (failure) => null,
        (scores) async {
          final batch = _database.batch();
          for (final score in scores) {
            batch.insert(
              'department_scores',
              {
                'id': score.id,
                'departmentId': score.departmentId,
                'score': score.score,
                'ranking': score.ranking,
                'examPeriod': score.examPeriod.toIso8601String(),
                'lastSynced': DateTime.now().toIso8601String(),
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await batch.commit();
        },
      );
    }
  }

  Future<List<Department>> _getLocalDepartments() async {
    final List<Map<String, dynamic>> maps = await _database.query('departments');
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

  Future<void> optimizeStorage() async {
    // Delete old data
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    await _database.delete(
      'department_scores',
      where: 'lastSynced < ?',
      whereArgs: [oneMonthAgo.toIso8601String()],
    );

    // Vacuum database
    await _database.execute('VACUUM');
  }

  Future<void> resolveConflicts() async {
    // Get all local data
    final localDepartments = await _getLocalDepartments();
    
    // Get remote data
    final remoteDepartments = await _repository.getDepartments(const FilterParams());
    
    remoteDepartments.fold(
      (failure) => throw Exception('Failed to resolve conflicts'),
      (remoteDepartments) async {
        // Compare and resolve conflicts
        for (final local in localDepartments) {
          final remote = remoteDepartments.firstWhere(
            (d) => d.id == local.id,
            orElse: () => local,
          );
          
          if (remote != local) {
            // Update local with remote data
            await _database.update(
              'departments',
              {
                'name': remote.name,
                'university': remote.university,
                'faculty': remote.faculty,
                'city': remote.city,
                'quota': remote.quota,
                'minScore': remote.minScore,
                'maxScore': remote.maxScore,
                'examPeriod': remote.examPeriod.toIso8601String(),
                'lastSynced': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [remote.id],
            );
          }
        }
      },
    );
  }

  @override
  Future<void> syncUserPreferences() {
    // Implementation needed
    throw UnimplementedError();
  }
} 