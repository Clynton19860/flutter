import 'package:json_annotation/json_annotation.dart';

part 'quote_model.g.dart';

enum Cover {
  thirdParty,
  thirdPartyFireTheft,
  comprehensive;

  double get factor => switch (this) {
        Cover.thirdParty => 0.6,
        Cover.thirdPartyFireTheft => 0.8,
        Cover.comprehensive => 1.0,
      };

  String get label => switch (this) {
        Cover.thirdParty => 'Third party',
        Cover.thirdPartyFireTheft => 'Third party, fire & theft',
        Cover.comprehensive => 'Comprehensive',
      };
}

@JsonSerializable()
class QuoteRequest {
  const QuoteRequest({
    required this.make,
    this.model,
    required this.year,
    required this.driverAge,
    required this.cover,
  });

  final String make;
  final String? model;
  final int year;
  final int driverAge;
  final Cover cover;

  QuoteRequest copyWith({
    String? make,
    String? model,
    int? year,
    int? driverAge,
    Cover? cover,
  }) =>
      QuoteRequest(
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        driverAge: driverAge ?? this.driverAge,
        cover: cover ?? this.cover,
      );

  Map<String, dynamic> toJson() => _$QuoteRequestToJson(this);

  factory QuoteRequest.fromJson(Map<String, dynamic> json) =>
      _$QuoteRequestFromJson(json);


  @override
  bool operator ==(Object other) =>
      other is QuoteRequest &&
      other.make == make &&
      other.model == model &&
      other.year == year &&
      other.driverAge == driverAge &&
      other.cover == cover;

  @override
  int get hashCode => Object.hash(make, model, year, driverAge, cover);
}

extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}

@JsonSerializable()
class Quote {
  const Quote({
    required this.id,
    required this.premium,
    this.currency = 'ZAR',
    this.breakdown,
  });

  final String id;
  final double premium;
  final String currency;
  @JsonKey(name: 'breakdown_lines') // the API field name differs
  final List<String>? breakdown;

  String get display => '$currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}

double calculatePremium(QuoteRequest r) {
  var p = 1000.0;
  if (r.driverAge < 25) p *= 1.5;
  if (r.year < 2015) p *= 1.2;
  p *= r.cover.factor;
  return (p * 100).roundToDouble() / 100;
}

sealed class QuoteState {
  const QuoteState();
}

class QuoteIdle extends QuoteState {
  const QuoteIdle();
}

class QuoteLoading extends QuoteState {
  const QuoteLoading();
}

class QuoteLoaded extends QuoteState {
  const QuoteLoaded(this.quote);
  final Quote quote;
}

class QuoteFailed extends QuoteState {
  const QuoteFailed(this.message);
  final String message;
}

class QuoteExpired extends QuoteState {
  const QuoteExpired(this.message);
  final String message;
}
