import 'dart:async';

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
}

// ---------- 3. Quote ----------
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

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    id: json['id'] as String,
    premium: (json['premium'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'ZAR',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'premium': premium,
    'currency': currency,
  };
}

double calculatePremium(QuoteRequest r) {
  double premium = 1000.0;

  if (r.driverAge < 25) {
    premium *= 1.5;
  }

  if (r.year < 2015) {
    premium *= 1.2;
  }

  premium *= r.cover.factor;

  return double.parse(premium.toStringAsFixed(2));
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
  final Quote quote;

  const QuoteLoaded(this.quote);
}

class QuoteFailed extends QuoteState {
  final String message;

  const QuoteFailed(this.message);
}

String describe(QuoteState s) => switch (s) {
  QuoteIdle() => 'Idle',
  QuoteLoading() => 'Loading...',
  QuoteLoaded(:final quote) => 'Loaded: ${quote.display}',
  QuoteFailed(:final message) => 'Failed: $message',
};


abstract interface class QuoteService {
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
}

Stream<QuoteState> quoteStates(QuoteService s, QuoteRequest r) async* {
  yield const QuoteLoading();
  try {
    yield QuoteLoaded(await s.getQuote(r));
  } catch (e) {
    yield QuoteFailed(e.toString());
  }
}


