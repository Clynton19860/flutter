// // ────────────────────────────────────────────────────────────
// // Flutter Day 1 · LAB 1.2 · Starter
// // Paste this WHOLE file into dartpad.dev, then press Run.
// // Handbook: README LAB 1.2
// // Fill in the TODOs. This compiles as-is, so Run works from
// // the first second and tells you the output you are aiming for.
// // DartPad reports "7 issues" - those are the 7 TODO markers below, not
// // errors. Treat the panel as your checklist: delete each TODO as you
// // implement it and the count walks down to 0.
// // ────────────────────────────────────────────────────────────

// // ---------- 1. Cover ----------
// enum Cover { thirdParty, thirdPartyFireTheft, comprehensive }

// double factor(Cover c) => switch (c) {
//   Cover.thirdParty => 0.6,
//   Cover.thirdPartyFireTheft => 0.8,
//   Cover.comprehensive => 1.0,
// };

// String band(int age) => switch (age) {
//   < 18 => 'not eligible',
//   >= 18 && < 25 => 'young driver',
//   >= 25 && < 65 => 'standard',
//   >= 65 => 'too old',
//   _ => 'standard',
// };

// class QuoteRequest {
//   final String make;
//   final String? model;
//   final int year;
//   final int driverAge;
//   final Cover cover;

//   const QuoteRequest(
//     this.cover, {
//     required this.make,
//     required this.year,
//     required this.driverAge,
//     required this.model,
//   });

//   QuoteRequest copyWith({
//     String? make,
//     String? model,
//     int? year,
//     int? driverAge,
//     required Cover cover,
//   }) {
//     return QuoteRequest(
//       this.cover,
//       make: make ?? this.make,
//       model: model ?? this.model,
//       year: year ?? this.year,
//       driverAge: driverAge ?? this.driverAge,
//     );
//   }
// }

// class Quote {
//   final String id;
//   final double premium;
//   final String currency;

//   const Quote({required this.id, required this.premium, this.currency = 'ZAR'});

//   String get display => '$currency ${premium.toStringAsFixed(2)}';

//   factory Quote.fromJson(Map<String, dynamic> j) => Quote(
//     id: j['id'] as String,
//     premium: (j['premium'] as num).toDouble(),
//     currency: j['currency'] as String? ?? 'ZAR',
//   );

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'premium': premium,
//     'currency': currency,
//   };
// }

// double calculatePremium(QuoteRequest r) {
//   final double base = 1000;
//   double loader = 0;
//   //   final loading = r.driverAge < 25
//   //       ? (r.year < 2015 ? 1.2 : 1.0)
//   //       : 1.0; // This, physically hurt to write

//   if (r.driverAge < 25) {
//     loader = base * 1.5;
//     print('loader dAge internal: ${loader}');
//   } else {
//     loader = base * 1.0;
//     print('loader dAge else internal: ${loader}');
//   }

//   print('loader Driver complete: ${loader}');

//   if (r.year < 2015) {
//     loader = loader * 1.2;
//     print('loader year less internal: ${loader}');
//   } else {
//     loader = loader * 1.0;
//     print('loader year more internal else: ${loader}');
//   }

//   print('loader complete year: ${loader}');

//   loader = loader * factor(r.cover);

//   print('loader final: ${loader}');

//   final result = double.parse(
//     loader.toStringAsFixed(2),
//   ); // LMAO this was very painful to write :'D
//   print('final result: ${result}');
//   return result;

//   //   final holdon = base * loading * factor(r.cover);
//   //   print('${holdon}');
//   //   final result = double.parse(
//   //     holdon.toStringAsFixed(2),
//   //   ); // LMAO this was very painful to write :'D
//   //   return result;
// }

// enum QuoteStates { idle, loading, loaded, failed }

// class QuoteResults {
//   final QuoteStates quoteState;
//   final Object payload;

//   const QuoteResults(this.quoteState, this.payload);
// }

// sealed class QuoteState {
//   final QuoteStates quoteState;
//   final Quote quote;

//   const QuoteState(this.quoteState, this.quote);

//   String describe(QuoteStates q) => switch (q) {
//     QuoteStates.idle => 'Fill in the form',
//     QuoteStates.loading => 'Calculating...',
//     QuoteStates.loaded => 'Premium ZAR 1000.00',
//     QuoteStates.failed => 'Error: too old',
//   };
// }

// void main() {
//   // TODO: build three requests with copyWith, print each premium
//   // TODO: print describe() for all four states

//   const quoteRequest1 = QuoteRequest(
//     make: 'VW',
//     model: 'Tiguan',
//     year: 2020,
//     driverAge: 22,
//     Cover.comprehensive,
//   );

//  var quoteRequest2 = quoteRequest1.copyWith(
// //     make: 'er',
// //     model: 'yo',
// //     year: 2020,
// //     driverAge: 22,
//     cover: Cover.thirdPartyFireTheft,
//   );

//   calculatePremium(quoteRequest1);
//   calculatePremium(quoteRequest2);

//   var quote1 = Quote(id: '1', premium: calculatePremium(quoteRequest1));

//   var quote2 = Quote(id: '2', premium: calculatePremium(quoteRequest2));

//   var quoteDisplay1 =
//       '${quoteRequest1.make} ${quoteRequest1.year} -> ${quote1.display}';

//   var quoteDisplay2 =
//       '${quoteRequest2.make} ${quoteRequest2.year} -> ${quote2.display}';
//   // Delete everything below once your code above runs.
//   for (final c in Cover.values) {
//     print('$c → ${factor(c)}');
//   }
//   print(quoteDisplay1);
//   print(quoteDisplay2);

//   print(band(66));
//   print('Lab 1.2 starter, nothing implemented yet.');
//   print('');
//   print('When you are done, Run should print exactly this:');
//   print('  VW 2020 -> R 1000.00');
//   print('  VW 2020 -> R 1500.00');
//   print('  VW 2012 -> R 720.00');
//   print('  Fill in the form');
//   print('  Calculating...');
//   print('  Premium ZAR 1000.00');
//   print('  Error: too old');
// }
// ────────────────────────────────────────────────────────────
// Flutter Day 1 · LAB 1.3 · Async quote service (complete)
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README LAB 1.3
// SELF-CONTAINED. Open a NEW pad and paste this.
// No need to merge it into your Lab 1.2 pad by hand.
// Takes ~6 seconds to run - the delays are deliberate.
// ────────────────────────────────────────────────────────────

import 'dart:async';

enum Cover {
  thirdParty, thirdPartyFireTheft, comprehensive;

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