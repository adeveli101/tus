import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String universityName;
  final String city;
  final String faculty;
  final String? subDepartment;
  final DateTime createdAt;
  final DateTime updatedAt;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.universityName,
    required this.city,
    required this.faculty,
    this.subDepartment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentModel(
      id: doc.id,
      name: data['name'] as String,
      universityName: data['universityName'] as String,
      city: data['city'] as String,
      faculty: data['faculty'] as String,
      subDepartment: data['subDepartment'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'universityName': universityName,
      'city': city,
      'faculty': faculty,
      'subDepartment': subDepartment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
} 