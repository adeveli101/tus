import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/exam_period.dart';

class ExamPeriodModel {
  static ExamPeriod fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamPeriod(
      id: doc.id,
      name: data['name'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  static ExamPeriod fromEntity(ExamPeriod entity) {
    return ExamPeriod(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  static Map<String, dynamic> toFirestore(ExamPeriod entity) {
    return {
      'name': entity.name,
      'startDate': Timestamp.fromDate(entity.startDate),
      'endDate': Timestamp.fromDate(entity.endDate),
    };
  }
} 