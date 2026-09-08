import 'dart:async';

enum Cover {
  thirdParty, thirdPartyFireTheft, comprehensive;
  double get factor => switch (this) {
        Cover.thirdParty => 0.6,
        Cover.thirdPartyFireTheft => 0.8,
        Cover.comprehensive => 1.0,
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

  QuoteRequest copyWith({String? make, String? model, int? year, int? driverAge, Cover? cover}) =>
      QuoteRequest(
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        driverAge: driverAge ?? this.driverAge,
        cover: cover ?? this.cover,
      );

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

class Quote {
  final String id;
  final double premium;
  final String currency;

  const Quote({required this.id, required this.premium, this.currency = 'ZAR'});

  String get display => '$currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        id: j['id'] as String,
        premium: (j['premium'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'ZAR',
      );

  Map<String, dynamic> toJson() => {'id': id, 'premium': premium, 'currency': currency};
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

String describe(QuoteState s) => switch (s) {
      QuoteIdle() => 'Fill in the form',
      QuoteLoading() => 'Calculating…',
      QuoteLoaded(:final quote) => 'Premium ${quote.display}',
      QuoteFailed(:final message) => 'Error: $message',
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
