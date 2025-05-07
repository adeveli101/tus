import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';
import 'package:tus/features/tus_scores/domain/entities/user.dart';

extension UserModel on User {
  static User fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      tusScore: data['tusScore'] as int,
      tusRanking: data['tusRanking'] as int,
      preferences: (data['preferences'] as List<dynamic>)
          .map((pref) => DepartmentPreference.fromJson(pref as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'tusScore': tusScore,
      'tusRanking': tusRanking,
      'preferences': preferences.map((pref) => pref.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 