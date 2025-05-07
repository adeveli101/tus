import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'advanced_filter_params.freezed.dart';
part 'advanced_filter_params.g.dart';

@JsonSerializable()
class RangeValuesConverter implements JsonConverter<RangeValues, Map<String, dynamic>> {
  const RangeValuesConverter();

  @override
  RangeValues fromJson(Map<String, dynamic> json) {
    return RangeValues(
      json['start'] as double,
      json['end'] as double,
    );
  }

  @override
  Map<String, dynamic> toJson(RangeValues range) {
    return {
      'start': range.start,
      'end': range.end,
    };
  }
}

@freezed
class AdvancedFilterParams with _$AdvancedFilterParams {
  const factory AdvancedFilterParams({
    @Default([]) List<String> cities,
    @Default([]) List<String> universities,
    @Default([]) List<String> faculties,
    @RangeValuesConverter() RangeValues? scoreRange,
    @RangeValuesConverter() RangeValues? quotaRange,
    @Default([]) List<String> tags,
    @Default(false) bool onlyFavorites,
    @Default(false) bool includeHistorical,
    DateTime? startDate,
    DateTime? endDate,
    @Default(false) bool hasQuota,
    @Default(false) bool hasScore,
  }) = _AdvancedFilterParams;

  factory AdvancedFilterParams.fromJson(Map<String, dynamic> json) =>
      _$AdvancedFilterParamsFromJson(json);
} 