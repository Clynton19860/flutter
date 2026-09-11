import 'package:json_annotation/json_annotation.dart';

part 'quote_model.g.dart';

// ---------- 1. Cover ----------
enum Cover {
  thirdParty,
  thirdPartyFireTheft,
  comprehensive;

  // TODO: double get factor => switch (this) { ... 0.6 / 0.8 / 1.0 ... };
  double get factor => switch (this) {
    Cover.thirdParty => 0.6,
    Cover.thirdPartyFireTheft => 0.8,
    Cover.comprehensive => 1.0,
  };

  String get label => switch (this) {
    Cover.thirdParty => 'Third Party',
    Cover.thirdPartyFireTheft => 'Third Party Fire & Theft',
    Cover.comprehensive => 'Comprehensive',
  };
}

// ---------- 2. QuoteRequest ----------
// TODO: fields make (String), model (String?), year (int), driverAge (int), cover (Cover)
//       const constructor with required named params
//       copyWith

@JsonSerializable()
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

  QuoteRequest copyWith({
    String? make,
    String? model,
    int? year,
    int? driverAge,
    Cover? cover,
  }) {
    return QuoteRequest(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      driverAge: driverAge ?? this.driverAge,
      cover: cover ?? this.cover,
    );
  }

  factory QuoteRequest.fromJson(Map<String, dynamic> json) =>
      _$QuoteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteRequestToJson(this);
}

// ---------- 3. Quote ----------
// TODO: id (String), premium (double), currency defaulting to 'ZAR'
//       a `display` getter, fromJson / toJson

@JsonSerializable()
class Quote {
  final String id;
  final double premium;
  final String currency;

  Quote({required this.id, required this.premium, this.currency = 'ZAR'});

  String get display => '$id ${premium.toStringAsFixed(2)} $currency';
  String get formattedDisplay =>
      'ID: $id\nPremium: ${premium.toStringAsFixed(2)}\nCurrency: $currency';

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}

// ---------- 4. Premium calculation ----------
// TODO: double calculatePremium(QuoteRequest r)
//       base 1000; x1.5 if driverAge < 25; x1.2 if year < 2015; x cover.factor
//       round to 2 decimals

double calculatePremium(QuoteRequest r) {
  const int base = 1000;

  if (r.driverAge < 25) {
    return base * 1.5;
  } else if (r.year < 2015) {
    return base * 1.2;
  }

  return base * r.cover.factor;
}

// ---------- 5. Sealed state ----------
// TODO: sealed class QuoteState with Idle / Loading / Loaded(quote) / Failed(message)
//       String describe(QuoteState s) using an exhaustive switch expression

String describe(QuoteState state) => switch (state) {
  Idle() => 'Fill in the form',
  Loading() => 'Calculating...',
  Loaded(:final quote) => quote.display,
  Failed(:final message) => 'Error: $message',
};

sealed class QuoteState {}

class Idle implements QuoteState {}

class Loading implements QuoteState {
  const Loading();
}

class Loaded implements QuoteState {
  final Quote quote;

  Loaded({required this.quote});
}

class Failed implements QuoteState {
  String? message;

  Failed({this.message = 'Something went wrong'});
}
//TODO: Add QuoteExpired State

/*abstract interface class QuoteService {
  Future<Quote> getQuote(QuoteRequest r);
}

class FakeQuoteService implements QuoteService {
  @override
  Future<Quote> getQuote(QuoteRequest r) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (r.year < 2000) throw Exception('Vehicle too old to insure');
    return Quote(id: 'q-${r.hashCode}', premium: calculatePremium(r));
  }
}

Future<void> runOnce(QuoteService s, QuoteRequest r) async {
  try {
    final q = await s.getQuote(r).timeout(const Duration(seconds: 3));
    print('OK ${q.display}');
  } on TimeoutException {
    print('Timed out');
  } catch (e) {
    print('Failed: $e');
  }
}*/
