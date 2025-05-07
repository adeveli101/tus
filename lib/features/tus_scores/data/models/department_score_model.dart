import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';

extension DepartmentScoreModel on DepartmentScore {
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

  Map<String, dynamic> toFirestore() {
    return {
      'departmentId': departmentId,
      'score': score,
      'ranking': ranking,
      'examPeriod': Timestamp.fromDate(examPeriod),
    };
  }
} 