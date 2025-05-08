import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';

class DepartmentScoreModel {
  static DepartmentScore fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentScore(
      id: doc.id,
      departmentId: data['departmentId'] as String,
      score: (data['score'] as num).toInt(),
      ranking: (data['ranking'] as num).toInt(),
      examPeriod: (data['examPeriod'] as Timestamp).toDate(),
    );
  }

  static DepartmentScore fromEntity(DepartmentScore entity) {
    return DepartmentScore(
      id: entity.id,
      departmentId: entity.departmentId,
      score: entity.score,
      ranking: entity.ranking,
      examPeriod: entity.examPeriod,
    );
  }

  static Map<String, dynamic> toFirestore(DepartmentScore entity) {
    return {
      'departmentId': entity.departmentId,
      'score': entity.score,
      'ranking': entity.ranking,
      'examPeriod': Timestamp.fromDate(entity.examPeriod),
    };
  }
} 