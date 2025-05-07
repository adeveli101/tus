import 'package:cloud_firestore/cloud_firestore.dart';

class ExamPeriodModel {
  final String id;
  final int year;
  final String term;
  final DateTime examDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamPeriodModel({
    required this.id,
    required this.year,
    required this.term,
    required this.examDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamPeriodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamPeriodModel(
      id: doc.id,
      year: data['year'] as int,
      term: data['term'] as String,
      examDate: (data['examDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'year': year,
      'term': term,
      'examDate': Timestamp.fromDate(examDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
} 