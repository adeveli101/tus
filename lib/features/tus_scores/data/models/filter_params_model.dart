import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';

part 'filter_params_model.freezed.dart';
part 'filter_params_model.g.dart';

@freezed
class FilterParamsModel with _$FilterParamsModel {
  const factory FilterParamsModel({
    @JsonKey(
      fromJson: _dateTimeFromTimestamp,
      toJson: _dateTimeToTimestamp,
    )
    DateTime? examPeriod,
    String? city,
    String? university,
    String? faculty,
  }) = _FilterParamsModel;

  factory FilterParamsModel.fromJson(Map<String, dynamic> json) =>
      _$FilterParamsModelFromJson(json);

  factory FilterParamsModel.fromEntity(FilterParams entity) => FilterParamsModel(
        examPeriod: entity.examPeriod,
        city: entity.city,
        university: entity.university,
        faculty: entity.faculty,
      );
}

DateTime? _dateTimeFromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  throw ArgumentError('Invalid timestamp value: $value');
}

Timestamp? _dateTimeToTimestamp(DateTime? date) {
  if (date == null) return null;
  return Timestamp.fromDate(date);
} 