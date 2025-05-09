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
      // Örnek: Sadece aktif uzmanlık dallarını kategorilere ayırarak dön
      final Map<String, List<String>> categories = Map<String, List<String>>.from(tusData["aktifTusUzmanlikDallariListesi"]);
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
    final List<String> allDepartments = [
      ...List<String>.from(tusData["aktifTusUzmanlikDallariListesi"]["dahiliTipBilimleri"]),
      ...List<String>.from(tusData["aktifTusUzmanlikDallariListesi"]["cerrahiTipBilimleri"]),
      ...List<String>.from(tusData["aktifTusUzmanlikDallariListesi"]["temelTipBilimleri"]),
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
    final List<String> departments = List<String>.from(tusData["aktifTusUzmanlikDallariListesi"][categoryId] ?? []);
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