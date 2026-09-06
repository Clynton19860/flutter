// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Collections
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Collections
// NOTE: fold needs an explicit <double> or Dart infers Object? and
// the + fails to compile.
// ────────────────────────────────────────────────────────────

void main() {
  final makes = <String>['Toyota', 'VW', 'BMW'];
  final byMake = {'VW': 1200.0, 'BMW': 2100.0};
  const showLuxury = true;

  final list = [
    'Toyota',
    if (showLuxury) 'BMW',                       // collection-if
    for (final m in makes) m.toUpperCase(),      // collection-for
    ...makes,                                    // spread
  ];
  print(list);

  final cheap = byMake.entries
      .where((e) => e.value < 2000)
      .map((e) => e.key)
      .toList();                                 // <-- .toList() matters
  print(cheap);

  print(byMake.values.fold<double>(0.0, (a, b) => a + b));
}
