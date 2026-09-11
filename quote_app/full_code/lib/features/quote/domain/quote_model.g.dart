// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteRequest _$QuoteRequestFromJson(Map<String, dynamic> json) => QuoteRequest(
  make: json['make'] as String,
  model: json['model'] as String?,
  year: (json['year'] as num).toInt(),
  driverAge: (json['driverAge'] as num).toInt(),
  cover: $enumDecode(_$CoverEnumMap, json['cover']),
);

Map<String, dynamic> _$QuoteRequestToJson(QuoteRequest instance) =>
    <String, dynamic>{
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'driverAge': instance.driverAge,
      'cover': _$CoverEnumMap[instance.cover]!,
    };

const _$CoverEnumMap = {
  Cover.thirdParty: 'thirdParty',
  Cover.thirdPartyFireTheft: 'thirdPartyFireTheft',
  Cover.comprehensive: 'comprehensive',
};

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
  id: json['id'] as String,
  premium: (json['premium'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'ZAR',
  breakdown: (json['breakdown_lines'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
  'id': instance.id,
  'premium': instance.premium,
  'currency': instance.currency,
  'breakdown_lines': instance.breakdown,
};
