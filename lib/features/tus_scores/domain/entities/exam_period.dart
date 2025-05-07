import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_period.freezed.dart';
part 'exam_period.g.dart';

@freezed
class ExamPeriod with _$ExamPeriod {
  const factory ExamPeriod({
    required String id,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) = _ExamPeriod;

  factory ExamPeriod.fromJson(Map<String, dynamic> json) =>
      _$ExamPeriodFromJson(json);
} 