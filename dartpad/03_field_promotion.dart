// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Fields do not promote
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Null safety
// The one that catches everybody: a nullable FIELD never promotes.
// Copy it to a local first.
// ────────────────────────────────────────────────────────────

class Driver {
  String? nickname;

  void greet() {
    // if (nickname != null) print(nickname.length);  // ERROR on a field
    final n = nickname;                               // copy to a local
    if (n != null) print(n.length);                   // now it promotes
    print(nickname?.length ?? 0);                     // or just be null-aware
  }
}

void main() => Driver()..nickname = 'Sive'..greet();
