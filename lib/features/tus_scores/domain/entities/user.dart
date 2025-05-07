import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tus/features/tus_scores/domain/entities/department_preference.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    required int tusScore,
    required int tusRanking,
    required List<DepartmentPreference> preferences,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
} 