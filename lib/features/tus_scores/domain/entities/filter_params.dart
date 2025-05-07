import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_params.freezed.dart';
part 'filter_params.g.dart';

@freezed
class FilterParams with _$FilterParams {
  const factory FilterParams({
    String? searchQuery,
    String? city,
    String? university,
    String? faculty,
    int? minQuota,
    int? maxQuota,
    double? minScore,
    double? maxScore,
    DateTime? examPeriod,
    @Default(false) bool onlyFavorites,
  }) = _FilterParams;

  factory FilterParams.fromJson(Map<String, dynamic> json) =>
      _$FilterParamsFromJson(json);
} 