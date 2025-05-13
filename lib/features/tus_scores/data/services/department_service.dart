import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/core/data/tus_data_loader.dart';

abstract class DepartmentService {
  Future<List<Department>> getAllDepartments();
  Future<List<Department>> getDepartmentsByType(String type);
  Future<List<Department>> getDepartmentsByYear(String year);
  Future<List<Department>> getDepartmentsByScoreRange(double minScore, double maxScore);
  Future<List<Department>> getDepartmentsByRankingRange(int minRanking, int maxRanking);
  Future<List<Department>> searchDepartments(String query);
  Future<List<String>> getAllBranches();
  Future<List<dynamic>> getQuotaChangesForBranch(String branch);
  Future<List<dynamic>> getUniversities();
  Future<List<dynamic>> getHospitals();
}

class DepartmentServiceImpl implements DepartmentService {
  final TusScoresRepository _repository;

  DepartmentServiceImpl({required TusScoresRepository repository})
      : _repository = repository;

  @override
  Future<List<Department>> getAllDepartments() async {
    final result = await _repository.getDepartments(const FilterParams());
    return result.fold(
      (failure) => throw Exception('Failed to get departments: $failure'),
      (departments) => departments,
    );
  }

  @override
  Future<List<Department>> getDepartmentsByType(String type) async {
    final departments = await getAllDepartments();
    return departments.where((d) => d.type == type).toList();
  }

  @override
  Future<List<Department>> getDepartmentsByYear(String year) async {
    final departments = await getAllDepartments();
    return departments.where((d) => d.year == year).toList();
  }

  @override
  Future<List<Department>> getDepartmentsByScoreRange(
      double minScore, double maxScore) async {
    final departments = await getAllDepartments();
    return departments
        .where((d) => d.score >= minScore && d.score <= maxScore)
        .toList();
  }

  @override
  Future<List<Department>> getDepartmentsByRankingRange(
      int minRanking, int maxRanking) async {
    final departments = await getAllDepartments();
    return departments
        .where((d) => d.ranking >= minRanking && d.ranking <= maxRanking)
        .toList();
  }

  @override
  Future<List<Department>> searchDepartments(String query) async {
    final departments = await getAllDepartments();
    final lowercaseQuery = query.toLowerCase();
    return departments.where((d) {
      return d.department.toLowerCase().contains(lowercaseQuery) ||
          d.institution.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<List<String>> getAllBranches() async {
    final tusData = await TusDataLoader.loadTusData();
    return [
      ...List<String>.from(tusData[0]["aktifTusUzmanlikDallariListesi"]["dahiliTipBilimleri"]),
      ...List<String>.from(tusData[0]["aktifTusUzmanlikDallariListesi"]["cerrahiTipBilimleri"]),
      ...List<String>.from(tusData[0]["aktifTusUzmanlikDallariListesi"]["temelTipBilimleri"]),
    ];
  }

  @override
  Future<List<dynamic>> getQuotaChangesForBranch(String branch) async {
    final tusData = await TusDataLoader.loadTusData();
    final List<dynamic> changes = List<dynamic>.from(tusData[0]["secilmisUzmanlikDallariKontenjanDegisimleri"]);
    return changes.where((e) => e["brans"] == branch).toList();
  }

  @override
  Future<List<dynamic>> getUniversities() async {
    final tusData = await TusDataLoader.loadTusData();
    return List<Map<String, dynamic>>.from(tusData[0]["tusEgitimiVerenUniversiteTipFakulteleriOrnekler"]);
  }

  @override
  Future<List<dynamic>> getHospitals() async {
    final tusData = await TusDataLoader.loadTusData();
    return List<Map<String, dynamic>>.from(tusData[0]["eahVeSehirHastaneleriOrnekler"]);
  }
}

class DepartmentServiceOld {
  Future<List<DepartmentCategory>> loadDepartments() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/departments.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      return jsonData.entries.map((entry) {
        final List<dynamic> departmentsJson = entry.value as List<dynamic>;
        final departments = departmentsJson.map((dept) => Department(
          id: dept['id'] as String,
          institution: dept['institution'] as String,
          department: dept['department'] as String,
          type: dept['type'] as String,
          year: dept['year'] as String,
          quota: dept['quota'] as String,
          score: (dept['score'] as num).toDouble(),
          ranking: dept['ranking'] as int,
          name: dept['name'] as String,
          university: dept['university'] as String,
          faculty: dept['faculty'] as String,
          city: dept['city'] as String,
          minScore: (dept['min_score'] as num).toDouble(),
          maxScore: (dept['max_score'] as num).toDouble(),
          examPeriod: dept['exam_period'] as String,
          isFavorite: dept['is_favorite'] as bool? ?? false,
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

  // Helper method to get all departments across all categories
  Future<List<Department>> getAllDepartments() async {
    final categories = await loadDepartments();
    return categories.expand((category) => category.departments).toList();
  }

  // Helper method to get departments by category
  Future<List<Department>> getDepartmentsByCategory(String categoryId) async {
    final categories = await loadDepartments();
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => throw Exception('Category not found: $categoryId'),
    );
    return category.departments;
  }

  // Helper method to search departments
  Future<List<Department>> searchDepartments(String query) async {
    final allDepartments = await getAllDepartments();
    final lowercaseQuery = query.toLowerCase();
    
    return allDepartments.where((dept) =>
      dept.institution.toLowerCase().contains(lowercaseQuery) ||
      dept.department.toLowerCase().contains(lowercaseQuery) ||
      dept.type.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Helper method to get departments by type
  Future<List<Department>> getDepartmentsByType(String type) async {
    final allDepartments = await getAllDepartments();
    return allDepartments.where((dept) => dept.type == type).toList();
  }

  // Helper method to get departments by year
  Future<List<Department>> getDepartmentsByYear(String year) async {
    final allDepartments = await getAllDepartments();
    return allDepartments.where((dept) => dept.year == year).toList();
  }

  // Helper method to get departments by score range
  Future<List<Department>> getDepartmentsByScoreRange(double minScore, double maxScore) async {
    final allDepartments = await getAllDepartments();
    return allDepartments.where((dept) => 
      dept.score >= minScore && dept.score <= maxScore
    ).toList();
  }

  // Helper method to get departments by ranking range
  Future<List<Department>> getDepartmentsByRankingRange(int minRanking, int maxRanking) async {
    final allDepartments = await getAllDepartments();
    return allDepartments.where((dept) => 
      dept.ranking >= minRanking && dept.ranking <= maxRanking
    ).toList();
  }
} 