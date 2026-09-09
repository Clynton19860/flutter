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
    Cover.thirdParty => 'Third party',
    Cover.thirdPartyFireTheft => 'Third party, fire & theft',
    Cover.comprehensive => 'Comprehensive',
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

String describe(QuoteState s) => switch (s) {
  Idle() => 'Fill in the form',
  Loading() => 'Calculating…',
  Loaded(:final quote) => 'Premium ${quote.display}',
  Failed(:final message) => 'Error: $message',
};

void main() {
  // 1st request
  final request1 = QuoteRequest(
    make: 'VW',
    model: 'null',
    year: 2020,
    driverAge: 30,
    cover: Cover.comprehensive,
  );

  // 2nd request
  final request2 = request1.copyWith(
    driverAge: 22,
  );
  // third request
  final request3 = request1.copyWith(
    year: 2012,
    cover: Cover.thirdPartyFireTheft,
  );
  
  // TODO: build three requests with copyWith, print each premium
  // TODO: print describe() for all four states
  print('${request1.make} ${request1.year} → R ${calculatePremium(request1).toStringAsFixed(2)}');
  
  print('${request2.make} ${request2.year} → R ${calculatePremium(request2).toStringAsFixed(2)}');
  
  print('${request3.make} ${request3.year} → R ${calculatePremium(request3).toStringAsFixed(2)}');

  print(describe(Idle()));
  print(describe(Loading()));
  print('${request3.make} ${request3.year} → R ${calculatePremium(request3).toStringAsFixed(2)}');

  print(describe(Idle()));
  print(describe(Loading()));
  print(describe(Loaded(
    Quote(id: 'Q001', premium: 1000),
  )));
  
  print(describe(Failed('too old')));
}
extension ZarFormat on double {
  String get rands => 'R${toStringAsFixed(2)}';
}