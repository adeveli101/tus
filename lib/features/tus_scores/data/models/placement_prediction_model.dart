import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';

extension PlacementPredictionModel on PlacementPrediction {
  static PlacementPrediction fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlacementPrediction(
      department: Department.fromJson(data['department'] as Map<String, dynamic>),
      probability: (data['probability'] as num).toDouble(),
      averageScore: (data['averageScore'] as num).toDouble(),
      minScore: (data['minScore'] as num).toDouble(),
      maxScore: (data['maxScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'department': department.toJson(),
      'probability': probability,
      'averageScore': averageScore,
      'minScore': minScore,
      'maxScore': maxScore,
    };
  }
} 