// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Classes
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Classes
// ────────────────────────────────────────────────────────────

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

void main() {
  const q = Quote(id: 'q1', premium: 1450);
  print(q.display);
  print(q.toJson());
  print(Quote.fromJson({'id': 'q2', 'premium': 900}).display);
}
