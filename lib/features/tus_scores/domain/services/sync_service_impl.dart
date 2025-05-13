import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/comparison_service.dart';
import 'package:dartz/dartz.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/features/tus_scores/domain/services/sync_service.dart';

import '../entities/filter_params.dart';

class SyncServiceImpl implements SyncService {
  final TusScoresRepository _repository;
  final Database _database;
  final Connectivity _connectivity;

  SyncServiceImpl({
    required TusScoresRepository repository,
    required Database database,
    required Connectivity connectivity,
  })  : _repository = repository,
        _database = database,
        _connectivity = connectivity;

  @override
  Future<void> syncData() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }
    await syncDepartments();
    await _optimizeStorage();
  }

  @override
  Future<void> syncDepartments() async {
    // Supabase ile senkronizasyon kodu eklenebilir.
    // Şimdilik sadece local işlemler.
    final departments = await _repository.getDepartments(const FilterParams());
    departments.fold(
      (failure) => throw Exception('Failed to get departments: $failure'),
      (departments) async {
        // Supabase ile sync işlemleri burada yapılabilir.
      },
    );
  }

  @override
  Future<void> syncDepartment(String id) async {
    // Supabase ile senkronizasyon kodu eklenebilir.
    final department = await _repository.getDepartmentById(id);
    department.fold(
      (failure) => throw Exception('Failed to get department: $failure'),
      (department) async {
        // Supabase ile sync işlemleri burada yapılabilir.
      },
    );
  }

  Future<void> _optimizeStorage() async {
    // Delete old data
    final oldData = await _database.query(
      'departments',
      where: 'year < ?',
      whereArgs: [DateTime.now().year.toString()],
    );
    for (final data in oldData) {
      await _database.delete(
        'departments',
        where: 'id = ?',
        whereArgs: [data['id']],
      );
    }
    // Vacuum the database
    await _database.execute('VACUUM');
  }

  @override
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

  @override
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
                'institution': remote.institution,
                'department': remote.department,
                'type': remote.type,
                'year': remote.year,
                'quota': remote.quota,
                'score': remote.score,
                'ranking': remote.ranking,
                'name': remote.name,
                'university': remote.university,
                'faculty': remote.faculty,
                'city': remote.city,
                'minScore': remote.minScore,
                'maxScore': remote.maxScore,
                'examPeriod': remote.examPeriod,
                'is_favorite': remote.isFavorite ? 1 : 0,
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
  Future<void> syncUserPreferences() async {
    // Implementation needed
    throw UnimplementedError();
  }

  Future<List<Department>> _getLocalDepartments() async {
    final List<Map<String, dynamic>> maps = await _database.query('departments');
    return List.generate(maps.length, (i) {
      return Department(
        id: maps[i]['id'] as String,
        institution: maps[i]['institution'] as String,
        department: maps[i]['department'] as String,
        type: maps[i]['type'] as String,
        year: maps[i]['year'] as String,
        quota: maps[i]['quota'].toString(),
        score: (maps[i]['score'] as num).toDouble(),
        ranking: maps[i]['ranking'] as int,
        name: maps[i]['name'] as String,
        university: maps[i]['university'] as String,
        faculty: maps[i]['faculty'] as String,
        city: maps[i]['city'] as String,
        minScore: (maps[i]['minScore'] as num).toDouble(),
        maxScore: (maps[i]['maxScore'] as num).toDouble(),
        examPeriod: maps[i]['examPeriod'] as String,
        isFavorite: maps[i]['is_favorite'] == 1,
      );
    });
  }
} 