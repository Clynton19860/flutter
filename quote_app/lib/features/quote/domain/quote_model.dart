
// LAB 1.2 — QUOTE DOMAIN MODEL


// ---------- 1. Cover ----------

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

// ---------- 2. QuoteRequest ----------

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

  String get display {
    return '$currency ${premium.toStringAsFixed(2)}';
  }

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

// ---------- 4. Money Extension ----------

extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}

// ---------- 5. Premium Calculation ----------

double calculatePremium(QuoteRequest request) {
  double premium = 1000;

  // Young driver loading
  if (request.driverAge < 25) {
    premium *= 1.5;
  }

  // Older vehicle loading
  if (request.year < 2015) {
    premium *= 1.2;
  }

  // Cover factor
  premium *= request.cover.factor;

  // Round to 2 decimal places
  return (premium * 100).round() / 100;
}

// ---------- 6. Sealed Quote State ----------

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

// ---------- 7. Describe Quote State ----------

String describe(QuoteState state) {
  return switch (state) {
    Idle() => 'Fill in the form',
    Loading() => 'Calculating…',
    Loaded(:final quote) => 'Premium ${quote.display}',
    Failed(:final message) => 'Error: $message',
  };
}
