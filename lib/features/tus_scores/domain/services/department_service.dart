import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_category.dart';

abstract class DepartmentService {
  Future<List<DepartmentCategory>> loadDepartments();
  Future<List<Department>> getDepartments();
  Future<List<Department>> getDepartmentsByScoreRange(double minScore, double maxScore);
  Future<List<Department>> getDepartmentsByCategory(String categoryId);
  Future<List<Department>> getFavoriteDepartments();
  Future<void> toggleFavorite(String departmentId);
} 