import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/department_service.dart';

class DepartmentServiceImpl implements DepartmentService {
  final TusScoresRepository repository;

  DepartmentServiceImpl({
    required this.repository,
  });

  @override
  Future<List<DepartmentCategory>> loadDepartments() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/departments.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      return jsonData.entries.map((entry) {
        final List<dynamic> departmentsJson = entry.value as List<dynamic>;
        final departments = departmentsJson.map((dept) => Department(
          id: dept['id'] as String,
          institution: dept['universite'] as String,
          department: dept['bolum_adi'] as String,
          type: dept['type'] as String,
          year: dept['sinav_donemi'] as String,
          quota: dept['kontenjan'].toString(),
          score: (dept['min_puan'] as num).toDouble(),
          ranking: dept['ranking'] as int,
          name: dept['bolum_adi'] as String,
          university: dept['universite'] as String,
          faculty: dept['fakulte'] as String,
          city: dept['sehir'] as String,
          minScore: (dept['min_puan'] as num).toDouble(),
          maxScore: (dept['max_puan'] as num).toDouble(),
          examPeriod: dept['sinav_donemi'] as String,
          isFavorite: false,
        )).toList();

        return DepartmentCategory(
          id: entry.key,
          name: entry.key,
          departments: departments,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  @override
  Future<List<Department>> getDepartments() async {
    final result = await repository.getDepartments(const FilterParams());
    return result.fold(
      (failure) => throw Exception('Failed to get departments: $failure'),
      (departments) => departments,
    );
  }

  @override
  Future<List<Department>> getDepartmentsByScoreRange(double minScore, double maxScore) async {
    final result = await repository.getDepartments(const FilterParams());
    return result.fold(
      (failure) => throw Exception('Failed to get departments: $failure'),
      (departments) => departments.where((dept) => 
        dept.score >= minScore && dept.score <= maxScore
      ).toList(),
    );
  }

  @override
  Future<List<Department>> getDepartmentsByCategory(String categoryId) async {
    final result = await repository.getDepartments(const FilterParams());
    return result.fold(
      (failure) => throw Exception('Failed to get departments: $failure'),
      (departments) => departments.where((dept) => 
        dept.type == categoryId
      ).toList(),
    );
  }

  @override
  Future<List<Department>> getFavoriteDepartments() async {
    final result = await repository.getDepartments(const FilterParams());
    return result.fold(
      (failure) => throw Exception('Failed to get departments: $failure'),
      (departments) => departments.where((dept) => dept.isFavorite).toList(),
    );
  }

  @override
  Future<void> toggleFavorite(String departmentId) async {
    // Implementation needed
    throw UnimplementedError();
  }
} 