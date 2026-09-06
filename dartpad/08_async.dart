// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Async
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Async
// ────────────────────────────────────────────────────────────

Future<String> fetchQuote(String id) async {
  await Future.delayed(const Duration(milliseconds: 500));
  if (id.isEmpty) throw Exception('no id');
  return 'quote-$id';
}

Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

void main() async {
  try {
    print(await fetchQuote('q1'));
  } catch (e, st) {
    print('$e\n$st');
  }

  await for (final n in countdown(3)) {
    print(n);
  }

  final sw = Stopwatch()..start();
  await Future.wait([fetchQuote('a'), fetchQuote('b'), fetchQuote('c')]);
  print('3 in parallel took ${sw.elapsedMilliseconds} ms');   // ~500, not 1500
}
