import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/exam_period.dart';

extension ExamPeriodModel on ExamPeriod {
  static ExamPeriod fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamPeriod(
      id: doc.id,
      name: data['name'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
} 