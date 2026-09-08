// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Functions
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Functions
// DartPad shows 1 issue here: "use a function declaration rather than a
// variable assignment". That is the lint arguing with the lesson - storing a
// function IN A VARIABLE is exactly the point. Leave it.
// ────────────────────────────────────────────────────────────

double premium(double base, {required int age, bool comprehensive = true}) {
  final double loading = age < 25 ? 1.5 : 1.0;
  return comprehensive ? base * 1.4 * loading : base * loading;
}

void main() {
  print(premium(1000, age: 34));                        // 1400.0
  print(premium(1000, age: 22, comprehensive: false));   // 1500.0

  final int Function(int) twice = (x) => x * 2;
  print(twice(21));
}
