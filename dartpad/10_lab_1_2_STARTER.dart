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
enum Cover {
  thirdParty, thirdPartyFireTheft, comprehensive;

  // TODO: double get factor => switch (this) { ... 0.6 / 0.8 / 1.0 ... };
}

// ---------- 2. QuoteRequest ----------
// TODO: fields make (String), model (String?), year (int), driverAge (int), cover (Cover)
//       const constructor with required named params
//       copyWith

// ---------- 3. Quote ----------
// TODO: id (String), premium (double), currency defaulting to 'ZAR'
//       a `display` getter, fromJson / toJson

// ---------- 4. Premium calculation ----------
// TODO: double calculatePremium(QuoteRequest r)
//       base 1000; x1.5 if driverAge < 25; x1.2 if year < 2015; x cover.factor
//       round to 2 decimals

// ---------- 5. Sealed state ----------
// TODO: sealed class QuoteState with Idle / Loading / Loaded(quote) / Failed(message)
//       String describe(QuoteState s) using an exhaustive switch expression

void main() {
  // TODO: build three requests with copyWith, print each premium
  // TODO: print describe() for all four states

  // Delete everything below once your code above runs.
  print('Lab 1.2 starter, nothing implemented yet.');
  print('');
  print('When you are done, Run should print exactly this:');
  print('  VW 2020 -> R 1000.00');
  print('  VW 2020 -> R 1500.00');
  print('  VW 2012 -> R 720.00');
  print('  Fill in the form');
  print('  Calculating...');
  print('  Premium ZAR 1000.00');
  print('  Error: too old');
}
