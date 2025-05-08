import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/data/models/department_model.dart';
import 'package:tus/features/tus_scores/data/models/department_score_model.dart';
import 'package:tus/features/tus_scores/data/models/exam_period_model.dart';
import 'package:tus/features/tus_scores/data/models/user_model.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/entities/exam_period.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/entities/user.dart';

abstract class TusScoresRemoteDataSource {
  Future<List<Department>> getDepartments(FilterParams filterParams);
  Future<Department> getDepartmentById(String id);
  Future<List<DepartmentScore>> getDepartmentScores(String departmentId);
  Future<List<ExamPeriod>> getExamPeriods();
  Future<void> addDepartment(Department department);
  Future<void> addDepartmentScore(String departmentId, DepartmentScore score);
  Future<void> addExamPeriod(ExamPeriod examPeriod);
  Future<User> getUserById(String id);
  Future<void> updateUserPreferences(String userId, List<DepartmentPreference> preferences);
  Future<void> updateUserScore(String userId, int score, int ranking);
}

class TusScoresRemoteDataSourceImpl implements TusScoresRemoteDataSource {
  final FirebaseFirestore _firestore;

  TusScoresRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<Department>> getDepartments(FilterParams filterParams) async {
    try {
      Query query = _firestore.collection('departments');

      if (filterParams.examPeriod != null) {
        query = query.where('examPeriod', isEqualTo: filterParams.examPeriod);
      }
      if (filterParams.city != null) {
        query = query.where('city', isEqualTo: filterParams.city);
      }
      if (filterParams.university != null) {
        query = query.where('university', isEqualTo: filterParams.university);
      }
      if (filterParams.faculty != null) {
        query = query.where('faculty', isEqualTo: filterParams.faculty);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => DepartmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get departments: $e');
    }
  }

  @override
  Future<Department> getDepartmentById(String id) async {
    try {
      final doc = await _firestore.collection('departments').doc(id).get();
      if (!doc.exists) {
        throw Exception('Department not found');
      }
      return DepartmentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get department: $e');
    }
  }

  @override
  Future<List<DepartmentScore>> getDepartmentScores(String departmentId) async {
    try {
      final snapshot = await _firestore
          .collection('departments')
          .doc(departmentId)
          .collection('scores')
          .get();
      return snapshot.docs
          .map((doc) => DepartmentScoreModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get department scores: $e');
    }
  }

  @override
  Future<List<ExamPeriod>> getExamPeriods() async {
    try {
      final snapshot = await _firestore.collection('exam_periods').get();
      return snapshot.docs
          .map((doc) => ExamPeriodModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get exam periods: $e');
    }
  }

  @override
  Future<void> addDepartment(Department department) async {
    try {
      await _firestore.collection('departments').add(DepartmentModel.toFirestore(department));
    } catch (e) {
      throw Exception('Failed to add department: $e');
    }
  }

  @override
  Future<void> addDepartmentScore(String departmentId, DepartmentScore score) async {
    try {
      await _firestore
          .collection('departments')
          .doc(departmentId)
          .collection('scores')
          .add(score.toJson());
    } catch (e) {
      throw Exception('Failed to add department score: $e');
    }
  }

  @override
  Future<void> addExamPeriod(ExamPeriod examPeriod) async {
    try {
      await _firestore.collection('exam_periods').add(examPeriod.toJson());
    } catch (e) {
      throw Exception('Failed to add exam period: $e');
    }
  }

  @override
  Future<User> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(String userId, List<DepartmentPreference> preferences) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences.map((p) => p.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  @override
  Future<void> updateUserScore(String userId, int score, int ranking) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'tusScore': score,
        'tusRanking': ranking,
      });
    } catch (e) {
      throw Exception('Failed to update user score: $e');
    }
  }
} 