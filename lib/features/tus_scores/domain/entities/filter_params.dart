import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_params.freezed.dart';
part 'filter_params.g.dart';

@freezed
class FilterParams with _$FilterParams {
  const factory FilterParams({
    String? type,
    String? year,
    double? minScore,
    double? maxScore,
    int? minRanking,
    int? maxRanking,
    String? searchQuery,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? examPeriod,
    String? city,
    String? university,
    String? faculty,
  }) = _FilterParams;

  factory FilterParams.fromJson(Map<String, dynamic> json) =>
      _$FilterParamsFromJson(json);
}

DateTime? _dateTimeFromJson(String? date) =>
    date != null ? DateTime.parse(date) : null;

String? _dateTimeToJson(DateTime? date) =>
    date?.toIso8601String(); 