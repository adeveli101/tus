import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';

class DepartmentModel {
  static Department fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department(
      id: doc.id,
      institution: data['institution'] as String,
      department: data['department'] as String,
      type: data['type'] as String,
      year: data['year'] as String,
      quota: data['quota'] as String,
      score: (data['score'] as num).toDouble(),
      ranking: (data['ranking'] as num).toInt(),
      name: data['name'] as String,
      university: data['university'] as String,
      faculty: data['faculty'] as String,
      city: data['city'] as String,
      minScore: (data['minScore'] as num).toDouble(),
      maxScore: (data['maxScore'] as num).toDouble(),
      examPeriod: data['examPeriod'] is Timestamp 
          ? (data['examPeriod'] as Timestamp).toDate().toIso8601String()
          : data['examPeriod'] as String,
      isFavorite: data['isFavorite'] as bool? ?? false,
    );
  }

  static Department fromEntity(Department entity) {
    return Department(
      id: entity.id,
      institution: entity.institution,
      department: entity.department,
      type: entity.type,
      year: entity.year,
      quota: entity.quota,
      score: entity.score,
      ranking: entity.ranking,
      name: entity.name,
      university: entity.university,
      faculty: entity.faculty,
      city: entity.city,
      minScore: entity.minScore,
      maxScore: entity.maxScore,
      examPeriod: entity.examPeriod,
      isFavorite: entity.isFavorite,
    );
  }

  static Map<String, dynamic> toFirestore(Department entity) {
    return {
      'institution': entity.institution,
      'department': entity.department,
      'type': entity.type,
      'year': entity.year,
      'quota': entity.quota,
      'score': entity.score,
      'ranking': entity.ranking,
      'name': entity.name,
      'university': entity.university,
      'faculty': entity.faculty,
      'city': entity.city,
      'minScore': entity.minScore,
      'maxScore': entity.maxScore,
      'examPeriod': entity.examPeriod,
      'isFavorite': entity.isFavorite,
    };
  }
} 