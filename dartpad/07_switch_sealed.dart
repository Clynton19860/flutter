// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Switch expressions
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Switch expressions
// ────────────────────────────────────────────────────────────

enum Cover { thirdParty, thirdPartyFireTheft, comprehensive }

double factor(Cover c) => switch (c) {
      Cover.thirdParty => 0.6,
      Cover.thirdPartyFireTheft => 0.8,
      Cover.comprehensive => 1.0,
    };

String band(int age) => switch (age) {
      < 18 => 'not eligible',
      >= 18 && < 25 => 'young driver',
      _ => 'standard',
    };

void main() {
  for (final c in Cover.values) {
    print('$c → ${factor(c)}');
  }
  print(band(22));
}
