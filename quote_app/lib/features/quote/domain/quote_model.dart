enum Cover {
  thirdParty,
  thirdPartyFireTheft,
  comprehensive;

  // DONE: double get factor => switch (this) { ... 0.6 / 0.8 / 1.0 ... };
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

// ---------- 2. QuoteRequest ----------
// DONE: fields make (String), model (String?), year (int), driverAge (int), cover (Cover)
//       const constructor with required named params
class QuoteRequest {
  final String make;
  final String? model;
  final int year;
  final int driverAge;
  final Cover cover;

  const QuoteRequest({
    required this.make,
    this.model,
    required this.year,
    required this.driverAge,
    required this.cover,
  });

  // NOTE extra from slides
  QuoteRequest copyWith({
    String? make,
    String? model,
    int? year,
    int? driverAge,
    Cover? cover,
  }) => QuoteRequest(
    make: make ?? this.make,
    model: model ?? this.model,
    year: year ?? this.year,
    driverAge: driverAge ?? this.driverAge,
    cover: cover ?? this.cover,
  );
}

// NOTE extra from slides
extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}

// ---------- 3. Quote ----------
// DONE: id (String), premium (double), currency defaulting to 'ZAR'
//       a `display` getter, fromJson / toJson
class Quote {
  final String id;
  final double premium;
  final String currency;

  const Quote({required this.id, required this.premium, this.currency = "ZAR"});

  String get display => '$currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
    id: j['id'] as String,
    premium: (j['premium'] as num).toDouble(),
    currency: j['currency'] as String? ?? 'ZAR',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'premium': premium,
    'currency': currency,
  };
}
// ---------- 4. Premium calculation ----------
// DONE: double calculatePremium(QuoteRequest r)
//       base 1000; x1.5 if driverAge < 25; x1.2 if year < 2015; x cover.factor
//       round to 2 decimals

double calculatePremium(QuoteRequest r) {
  var p = 1000.0; // base 1000
  if (r.driverAge < 25) p *= 1.5; // x1.5 if driverAge < 25
  if (r.year < 2015) p *= 1.2; //x1.2 if year < 2015
  p *= r.cover.factor; // x cover.factor
  return (p * 100).roundToDouble() / 100; // round to 2 decimals
}

// ---------- 5. Sealed state ----------
// DONE: sealed class QuoteState with Idle / Loading / Loaded(quote) / Failed(message)
//       String describe(QuoteState s) using an exhaustive switch expression
sealed class QuoteState {
  // https://dart.dev/language/class-modifiers#sealed
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

String describe(QuoteState s) => switch (s) {
  QuoteIdle() => 'Fill in the form',
  QuoteLoading() => 'Calculating…',
  QuoteLoaded(:final quote) => 'Premium ${quote.display}',
  QuoteFailed(:final message) => 'Error: $message',
};
