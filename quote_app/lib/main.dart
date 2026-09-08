import 'dart:async';

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
}

// ---------- 2. QuoteRequest ----------
// TODO: fields make (String), model (String?), year (int), driverAge (int), cover (Cover)

class QuoteRequest {
  final String make;
  final String? model;
  final int year;
  final int driverAge;
  final Cover cover;
  
//       const constructor with required named params
//       copyWith
  const QuoteRequest({
  required this.make,
  this.model,
  required this.year,
  required this.driverAge,
  required this.cover,
});
  

  QuoteRequest copyWith({ String? make, String? model, int? year, int? driverAge,   Cover? cover,}) {
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
// TODO: id (String), premium (double), currency defaulting to 'ZAR'
//       a `display` getter, fromJson / toJson

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
  
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      premium: (json['premium'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ZAR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'premium': premium,
      'currency': currency,
    };
  }
}

// ---------- 4. Premium calculation ----------
// TODO: double calculatePremium(QuoteRequest r)
//       base 1000; x1.5 if driverAge < 25; x1.2 if year < 2015; x cover.factor
//       round to 2 decimals

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
sealed class QuoteState {}
class QuoteIdle extends QuoteState {}

class QuoteLoading extends QuoteState {}

class QuoteLoaded extends QuoteState {
  final Quote quote;

  QuoteLoaded(this.quote);
}

class QuoteFailed extends QuoteState {
  final String message;

  QuoteFailed(this.message);
}

// LAB 3
abstract interface class QuoteService{
  Future<Quote> getQuote(QuoteRequest r);
}

class FakeQuoteService implements QuoteService {
  @override
  Future<Quote> getQuote(QuoteRequest r) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (r.year < 2000) {
      throw Exception('Vehicle too old to insure');
    }

    return Quote(
      id: 'q-${r.hashCode}',
      premium: calculatePremium(r),
    );
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

void main() async {
  final svc = FakeQuoteService();
  const ok = QuoteRequest(make: 'VW', year: 2020, driverAge: 30, cover: Cover.comprehensive);

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


String describe(QuoteState s) => switch (s) {
  QuoteIdle() => 'Fill in the form',
  QuoteLoading() => 'Calculating…',
  QuoteLoaded(:final quote) => 'Premium ${quote.display}',
  QuoteFailed(:final message) => 'Error: $message',
};

