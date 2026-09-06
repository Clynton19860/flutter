// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Variables
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Variables
// ────────────────────────────────────────────────────────────

void main() {
  var count = 0;              // int, inferred, reassignable
  count = 5;
  // count = 'five';          // compile error: String is not int

  final createdAt = DateTime.now();   // set once, at runtime  (= JS const)
  const vatRate = 0.15;               // compile-time constant
  const brand = 'Alpha Insure';

  double premium = 1450.0;            // explicit type where it helps the reader
  List<String> makes = ['Toyota', 'VW'];

  print('$brand $count $createdAt $vatRate $premium $makes');
}
