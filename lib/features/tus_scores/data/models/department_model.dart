import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';

extension DepartmentModel on Department {
  static Department fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department(
      id: doc.id,
      name: data['name'] as String,
      university: data['university'] as String,
      faculty: data['faculty'] as String,
      city: data['city'] as String,
      quota: (data['quota'] as num).toInt(),
      minScore: (data['minScore'] as num).toDouble(),
      maxScore: (data['maxScore'] as num).toDouble(),
      examPeriod: (data['examPeriod'] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toFirestore(Department department) {
    return {
      'name': department.name,
      'university': department.university,
      'faculty': department.faculty,
      'city': department.city,
      'quota': department.quota,
      'minScore': department.minScore,
      'maxScore': department.maxScore,
      'examPeriod': Timestamp.fromDate(department.examPeriod),
    };
  }
} 