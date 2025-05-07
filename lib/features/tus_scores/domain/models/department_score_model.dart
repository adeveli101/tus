import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentScoreModel {
  final String id;
  final String departmentId;
  final String examPeriodId;
  final double baseScore;
  final int quota;
  final String scoreType;
  final int? minRank;
  final int? maxRank;
  final DateTime createdAt;
  final DateTime updatedAt;

  DepartmentScoreModel({
    required this.id,
    required this.departmentId,
    required this.examPeriodId,
    required this.baseScore,
    required this.quota,
    required this.scoreType,
    this.minRank,
    this.maxRank,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentScoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentScoreModel(
      id: doc.id,
      departmentId: data['departmentId'] as String,
      examPeriodId: data['examPeriodId'] as String,
      baseScore: (data['baseScore'] as num).toDouble(),
      quota: data['quota'] as int,
      scoreType: data['scoreType'] as String,
      minRank: data['minRank'] as int?,
      maxRank: data['maxRank'] as int?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'departmentId': departmentId,
      'examPeriodId': examPeriodId,
      'baseScore': baseScore,
      'quota': quota,
      'scoreType': scoreType,
      'minRank': minRank,
      'maxRank': maxRank,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
} 