import 'dart:async';
import 'dart:math';

enum Cover {
  thirdParty,
  thirdPartyFireTheft,
  comprehensive;

  // DONE: double get factor => switch (this) { ... 0.6 / 0.8 / 1.0 ... };
  double get factor =>
      switch (this) {
        Cover.thirdParty => 0.6,
        Cover.thirdPartyFireTheft => 0.8,
        Cover.comprehensive => 1.0
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

  const QuoteRequest({required this.make, this.model, required this.year, required this.driverAge, required this.cover});

  // NOTE extra from slides
  QuoteRequest copyWith({String? make, String? model, int? year, int? driverAge, Cover? cover}) =>
      QuoteRequest(make: make ?? this.make, model: model ?? this.model, year: year ?? this.year,
          driverAge: driverAge ?? this.driverAge, cover: cover ?? this.cover);
}

// NOTE extra from slides
extension Money on double { String get rands => 'R ${toStringAsFixed(2)}'; }

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

  Map<String, dynamic> toJson() => {'id': id, 'premium': premium, 'currency': currency};
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
sealed class QuoteState {  // https://dart.dev/language/class-modifiers#sealed
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

// Lab 1.3
// ... keep everything from Lab 1.2 above this line ...

abstract interface class QuoteService {
  Future<Quote> getQuote(QuoteRequest r);
}

class FakeQuoteService implements QuoteService {
  final _rand = Random();

  @override
  Future<Quote> getQuote(QuoteRequest r) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (r.year < 2000) throw Exception('Vehicle too old to insure');
    if (_rand.nextDouble() < 0.3) {
      throw Exception('Service temporarily unavailable');
    }
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

Future<Quote> _getQuoteWithRetry(QuoteService s, QuoteRequest r) async {
  try {
    return await s.getQuote(r);
  } catch (_) {
    await Future.delayed(const Duration(milliseconds: 500)); // back-off
    return s.getQuote(r); // one retry, let it throw if it fails again
  }
}

Stream<QuoteState> quoteStates(QuoteService s, QuoteRequest r) async* {
  yield const QuoteLoading();
  try {
    yield QuoteLoaded(await _getQuoteWithRetry(s, r));
  } catch (e) {
    yield QuoteFailed(e.toString());
  }
}
void main() async {
  // Lab 1
  // DONE: build three requests with copyWith, print each premium
  // DONE: print describe() for all four states
  const base = QuoteRequest(
      make: 'VW', year: 2020, driverAge: 30, cover: Cover.comprehensive);
  final young = base.copyWith(driverAge: 22);
  final old = base.copyWith(year: 2012, cover: Cover.thirdParty);
  for (final r in [base, young, old])
    print('${r.make} ${r.year} → ${calculatePremium(r).rands}');
  for (final s in [
    const QuoteIdle(),
    const QuoteLoading(),
    QuoteLoaded(Quote(id: 'q1', premium: calculatePremium(base))),
    const QuoteFailed('too old')
  ]) {
    print(describe(s));

    // Lab 2
    final svc = FakeQuoteService();
    const ok = QuoteRequest(
        make: 'VW', year: 2020, driverAge: 30, cover: Cover.comprehensive);

    await runOnce(svc, ok);

    await for (final st in quoteStates(svc, ok).distinct()) { //https://api.flutter.dev/flutter/dart-async/Stream/distinct.html TODO confirm what was meant to change
      print(describe(st));
    }
    await for (final st in quoteStates(svc, ok.copyWith(year: 1998))) {
      print(describe(st));
    }

    final sw = Stopwatch()
      ..start();
    await Future.wait([svc.getQuote(ok), svc.getQuote(ok), svc.getQuote(ok)]);
    print(
        '3 parallel quotes in ${sw.elapsedMilliseconds} ms'); // ~1500, not 4500
  }
}
