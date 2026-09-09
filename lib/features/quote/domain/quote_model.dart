import 'dart:async';
// import 'dart:convert';
// 1:
enum Cover {
  thirdParty, thirdPartyFireTheft, comprehensive;

  double get factor => 
  switch (this) {
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

// 2:
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
    required this.cover
  });

  QuoteRequest copyWith({String? make, String? model, int? year, int? driverAge, Cover? cover,}) {
    return QuoteRequest(
      make: make ?? this.make, 
      model: model ?? this.model, 
      year: year ?? this.year, 
      driverAge: driverAge ?? this.driverAge, 
      cover: cover ?? this.cover
    );
  }

  @override
  String toString() => '$make ${model ?? ""} ($year), age=$driverAge, cover=$cover';
}

// 3:
class Quote {
  final String id;
  final double premium;
  final String currency;

  const Quote({
    required this.id, 
    required this.premium, 
    this.currency = 'ZAR',
  });

  String get display => '$currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> json){
    return Quote(
      id: json['id'] as String,
      premium: (json['premium'] as num).toDouble(),
      currency: json['currency'] as String ?? 'ZAR',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'premium': premium,
    'currency': currency
  };
}

// 4:
double premiumCalculation(QuoteRequest r) {
  double premium = 1000.0;

  if(r.driverAge < 25) premium *= 1.5;
  if(r.year < 2015) premium *= 1.2;
  premium *= r.cover.factor;

  return double.parse(premium.toStringAsFixed(2));
}

// 5:
sealed class QuoteState {}

class QuoteIdle extends QuoteState {}

class QuoteLoading extends QuoteState{}

class QuoteLoaded extends QuoteState{
  final Quote quote;
  QuoteLoaded(this.quote);
}

class QuoteFailed extends QuoteState {
  final String message;
  QuoteFailed(this.message);
}

String describe(QuoteState s) => switch(s) {
  QuoteIdle() => 'Idle',
  QuoteLoading() => 'Loading quote...',
  QuoteLoaded(:final quote) => 'Loaded: ${quote.display}',
  QuoteFailed(:final message) => 'Failed: $message',
};


// ... keep everything from Lab 1.2 above this line ...
abstract interface class QuoteService {
  Future<Quote> getQuote(QuoteRequest r);
}

class FakeQuoteService implements QuoteService {
  @override
  Future<Quote> getQuote(QuoteRequest r) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (r.year < 2000) throw Exception('Vehicle too old to insure');
    return Quote(id: 'q-${r.hashCode}', premium: premiumCalculation(r));
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
}

Stream<QuoteState> quoteStates(QuoteService s, QuoteRequest r) async* {
  yield QuoteLoading();
  try {
    yield QuoteLoaded(await s.getQuote(r));
  } catch (e) {
    yield QuoteFailed(e.toString());
  }
}

extension CurrencyFormatting on double {
  String get rands => 'ZAR ${toStringAsFixed(2)}';
}