import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';

extension DepartmentPreferenceModel on DepartmentPreference {
  static DepartmentPreference fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentPreference(
      id: doc.id,
      departmentId: data['departmentId'] as String,
      preferenceOrder: data['preferenceOrder'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'departmentId': departmentId,
      'preferenceOrder': preferenceOrder,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 