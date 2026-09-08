import 'dart:async';

// ---------- 1. Cover ----------
enum Cover {
  thirdParty, thirdPartyFireTheft, comprehensive;
  // TODO: double get factor => switch (this) { ... 0.6 / 0.8 / 1.0 ... };

  double get factor => switch (this){
    Cover.thirdParty => 0.6,
    Cover.thirdPartyFireTheft => 0.8,
    Cover.comprehensive => 1.0
  };
}


// ---------- 2. QuoteRequest ----------
// TODO: fields make (String), model (String?), year (int), driverAge (int), cover (Cover)
//       const constructor with required named params
//       copyWith

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

// ---------- 3. Quote ----------
// TODO: id (String), premium (double), currency defaulting to 'ZAR'
//       a `display` getter, fromJson / toJson
class Quote {
  final String id;
  final double premium;
  final String currency;

  const Quote({required this.id, required this.premium,  this.currency = 'ZAR'});

  String get display => '$currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
    id: j['id'] as String,
    premium: (j['premium'] as num).toDouble(),
    currency: j['currency'] as String? ?? 'ZA',
  );

  Map<String, dynamic> toJson() => {'id': id, 'premium': premium, 'currency': currency};
}

// ---------- 4. Premium calculation ----------
// TODO: double calculatePremium(QuoteRequest r)
//       base 1000; x1.5 if driverAge < 25; x1.2 if year < 2015; x cover.factor
//       round to 2 decimals
double calculatePremium(QuoteRequest r) {
  var p = 1000.0;
  if (r.driverAge < 25) p *= 1.5;
  if (r.year < 2015) p *= 1.2;
  p *= r.cover.factor;
  return (p * 100).roundToDouble() / 100;
}


// ---------- 5. Sealed state ----------
// TODO: sealed class QuoteState with Idle / Loading / Loaded(quote) / Failed(message)
//       String describe(QuoteState s) using an exhaustive switch expression
sealed class QuoteState {
  const QuoteState();
}

class Idle extends QuoteState {
  const Idle();
}

class Loading extends QuoteState {
  const Loading();
}

class Loaded extends QuoteState {
  const Loaded(this.quote);
  final Quote quote;
}

class Failed extends QuoteState {
  const Failed(this.message);
  final String message;
}

String describe(QuoteState s) => switch (s) {
  Idle() => 'Fill in the form',
  Loading() => 'Calculating…',
  Loaded(:final quote) => 'Premium ${quote.display}',
  Failed(:final message) => 'Error: $message',
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
  yield const Loading();
  try {
    yield Loaded(await s.getQuote(r));
  } catch (e) {
    yield Failed(e.toString());
  }
}

void main() async {
  // TODO: build three requests with copyWith, print each premium
  // TODO: print describe() for all four states
  const q = Quote(id: 'q1', premium: 1450);
  print(q.display);
  print(q.toJson());
  print(Quote.fromJson({'id': 'q2', 'premium': 700}).display);




}
