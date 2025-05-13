import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/department_service.dart';
import 'package:tus/core/data/tus_data_loader.dart';

class DepartmentServiceImpl implements DepartmentService {
  final TusScoresRepository repository;

  DepartmentServiceImpl({
    required this.repository,
  });

  @override
  Future<List<DepartmentCategory>> loadDepartments() async {
    try {
      final tusData = await TusDataLoader.loadTusData();
      final data = tusData.isNotEmpty ? tusData[0] : {};
      final Map<String, dynamic> categoriesRaw = Map<String, dynamic>.from(data["aktifTusUzmanlikDallariListesi"]);
      final Map<String, List<String>> categories = categoriesRaw.map((k, v) => MapEntry(k, List<String>.from(v)));
      return categories.entries.map((entry) {
        final departments = entry.value.map((name) => Department(
          id: name,
          institution: '',
          department: name,
          type: entry.key,
          year: '',
          quota: '',
          score: 0,
          ranking: 0,
          name: name,
          university: '',
          faculty: '',
          city: '',
          minScore: 0,
          maxScore: 0,
          examPeriod: '',
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
    final tusData = await TusDataLoader.loadTusData();
    final data = tusData.isNotEmpty ? tusData[0] : {};
    final List<String> allDepartments = [
      ...List<String>.from(data["aktifTusUzmanlikDallariListesi"]["dahiliTipBilimleri"]),
      ...List<String>.from(data["aktifTusUzmanlikDallariListesi"]["cerrahiTipBilimleri"]),
      ...List<String>.from(data["aktifTusUzmanlikDallariListesi"]["temelTipBilimleri"]),
    ];
    return allDepartments.map((name) => Department(
      id: name,
      institution: '',
      department: name,
      type: '',
      year: '',
      quota: '',
      score: 0,
      ranking: 0,
      name: name,
      university: '',
      faculty: '',
      city: '',
      minScore: 0,
      maxScore: 0,
      examPeriod: '',
      isFavorite: false,
    )).toList();
  }

  @override
  Future<List<Department>> getDepartmentsByScoreRange(double minScore, double maxScore) async {
    // tus_data.json'da skorlar yoksa, boş döndür
    return [];
  }

  @override
  Future<List<Department>> getDepartmentsByCategory(String categoryId) async {
    final tusData = await TusDataLoader.loadTusData();
    final data = tusData.isNotEmpty ? tusData[0] : {};
    final List<String> departments = List<String>.from(data["aktifTusUzmanlikDallariListesi"][categoryId] ?? []);
    return departments.map((name) => Department(
      id: name,
      institution: '',
      department: name,
      type: categoryId,
      year: '',
      quota: '',
      score: 0,
      ranking: 0,
      name: name,
      university: '',
      faculty: '',
      city: '',
      minScore: 0,
      maxScore: 0,
      examPeriod: '',
      isFavorite: false,
    )).toList();
  }

  @override
  Future<List<Department>> getFavoriteDepartments() async {
    // Favori departmanlar için ek bir yapı yoksa, boş döndür
    return [];
  }

  @override
  Future<void> toggleFavorite(String departmentId) async {
    // Favori işlemi için ek bir yapı yoksa, boş bırak
    throw UnimplementedError();
  }
} 