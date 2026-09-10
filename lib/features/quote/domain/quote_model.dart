// ────────────────────────────────────────────────────────────
// Flutter Day 1 · LAB 1.2 · Starter
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README LAB 1.2
// Fill in the TODOs. This compiles as-is, so Run works from
// the first second and tells you the output you are aiming for.
// DartPad reports "7 issues" - those are the 7 TODO markers below, not
// errors. Treat the panel as your checklist: delete each TODO as you
// implement it and the count walks down to 0.
// ────────────────────────────────────────────────────────────
// ---------- 1. Cover ----------
// import '12_lab_1_3_COMPLETE.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';

enum Cover {
  thirdParty, 
  thirdPartyFireTheft, 
  comprehensive;

  double get factor => switch (this) {
     Cover.thirdParty => 0.6,
     Cover.thirdPartyFireTheft => 0.8,
     Cover.comprehensive => 1.0
     };

  String get label => switch (this) {
    Cover.thirdParty => 'Third party',
    Cover.thirdPartyFireTheft => 'Third party, fire and theft',
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
    required this.cover
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
      cover: cover ?? this.cover
    );
  }
}

class Quote {
  final String id;
  final double premium;
  final String currency;

  Quote({
    required this.id,
    required this.premium,
    this.currency = 'ZAR',
  });

  String get display => 'Premium $currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      premium: json['premium'],
      currency: json['currency'] ?? 'ZAR',
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


double calculatePremium(QuoteRequest r) {
  double premium = 1000;

  if (r.driverAge < 25) {
    premium *= 1.5;
  }

  if (r.year < 2015) {
    premium *= 1.2;
  }

  return double.parse(premium.toStringAsFixed(2));
}

sealed class QuoteState{}

class Idle extends QuoteState{} // nothing happens yet

class Loading extends QuoteState{}

class Loaded extends QuoteState{
  final Quote quote;

  Loaded(this.quote);
}

class Failed extends QuoteState {
  final String message;

  Failed(this.message);
}

String describe(QuoteState s) => switch (s) {
  Idle() => 'Fill in the form',
  Loading() => 'Calculating...',
  Loaded(:final quote) => quote.display,
  Failed(:final message) => 'Error: $message',
};


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

extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}