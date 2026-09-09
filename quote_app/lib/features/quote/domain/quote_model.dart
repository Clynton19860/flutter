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
}
// TODO: double get factor => switch (this) { ... 0.6 / 0.8 / 1.0 ... };

// ---------- 2. QuoteRequest ----------
// TODO: fields make (String), model (String?), year (int), driverAge (int), cover (Cover)
//       const constructor with required named params
//       copyWith
class QuoteRequest {
  final String? model;
  final int year;
  final int driverAge;
  final Cover cover;
  final String? make;

  const QuoteRequest({
    required this.make,
    this.model,
    required this.year,
    required this.driverAge,
    required this.cover,
  });

  QuoteRequest copyWith({
    String? model,
    int? year,
    int? driverAge,
    Cover? cover,
    String? make,
  }) {
    return QuoteRequest(
      model: model ?? this.model,
      year: year ?? this.year,
      driverAge: driverAge ?? this.driverAge,
      cover: cover ?? this.cover,
      make: make ?? this.make,
    );
  }
}

const request = QuoteRequest(
  model: 'Toyota Corolla',
  year: 2022,
  driverAge: 30,
  cover: Cover.comprehensive,
  make: 'toyota',
);

// ---------- 3. Quote ----------
// TODO: id (String), premium (double), currency defaulting to 'ZAR'
//       a `display` getter, fromJson / toJson
class Quote {
  final String id;
  final double premium;
  final String currency;

  const Quote({required this.id, required this.premium, this.currency = 'ZAR'});

  String get display => '$currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      premium: (json['premium'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ZAR',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'premium': premium, 'currency': currency};
  }
}

// ---------- 4. Premium calculation ----------
// TODO: double calculatePremium(QuoteRequest r)
//       base 1000; x1.5 if driverAge < 25; x1.2 if year < 2015; x cover.factor
//       round to 2 decimals4
double calculatePremium(QuoteRequest r) {
  double premium = 1000;

  if (r.driverAge < 25) {
    premium *= 1.5;
  }

  if (r.year < 2015) {
    premium *= 1.2;
  }

  premium *= r.cover.factor;

  return double.parse(premium.toStringAsFixed(2));
}

// ---------- 5. Sealed state ----------
// TODO: sealed class QuoteState with Idle / Loading / Loaded(quote) / Failed(message)
//       String describe(QuoteState s) using an exhaustive switch expression
// ---------- 5. Sealed state ----------

String describe(QuoteState s) => switch (s) {
  Idle() => 'Idle',
  Loading() => 'Loading...',
  Loaded(:final quote) => 'Loaded: ${quote.display}',
  Failed(:final message) => 'Failed: $message',
};

sealed class QuoteState {}

class Idle extends QuoteState {}

class Loading extends QuoteState {}

class Loaded extends QuoteState {
  final Quote quote;

  Loaded(this.quote);
}

class Failed extends QuoteState {
  final String message;

  Failed(this.message);
}

// void main() {
//   // Base request
//   final request1 = QuoteRequest(
//     model: 'Toyota Corolla',
//     year: 2020,
//     driverAge: 30,
//     cover: Cover.thirdParty,
//     make: 'toyota',
//   );

//   // Create copies with changes
//   final request2 = request1.copyWith(driverAge: 22);

//   final request3 = request1.copyWith(year: 2010, cover: Cover.comprehensive);

//   // Print premiums
//   print('Request 1 premium: ${calculatePremium(request1)}');
//   print('Request 2 premium: ${calculatePremium(request2)}');
//   print('Request 3 premium: ${calculatePremium(request3)}');

//   // Create states
//   final idle = Idle();
//   final loading = Loading();
//   final loaded = Loaded(Quote(id: 'Q001', premium: calculatePremium(request1)));
//   final failed = Failed('Unable to calculate quote');

//   // Print state descriptions
//   print(describe(idle));
//   print(describe(loading));
//   print(describe(loaded));
//   print(describe(failed));
// }
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
  yield Loading();
  try {
    yield Loaded(await s.getQuote(r));
  } catch (e) {
    yield Failed(e.toString());
  }
}

void main() async {
  final svc = FakeQuoteService();
  const ok = QuoteRequest(make: 'VW', year: 2020, driverAge: 30, cover: Cover.comprehensive, model: "Toyota");

  await runOnce(svc, ok);

  await for (final st in quoteStates(svc, ok)) {
    print(describe(st));
  }
  await for (final st in quoteStates(svc, ok.copyWith(year: 1998))) {
    print(describe(st));
  }

  final sw = Stopwatch()..start();
  await Future.wait([svc.getQuote(ok), svc.getQuote(ok), svc.getQuote(ok)]);
  print('3 parallel quotes in ${sw.elapsedMilliseconds} ms');   // ~1500, not 4500
}



// ===========================
