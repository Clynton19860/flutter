// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Mixins and extensions
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Mixins and extensions
// ────────────────────────────────────────────────────────────

mixin Loggable {
  void log(String m) => print('[$runtimeType] $m');
}

extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}

class QuoteService with Loggable {
  void quote() => log('quoting…');
}

void main() {
  QuoteService().quote();
  print(1450.0.rands);          // R 1450.00
}
