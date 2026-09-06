// ────────────────────────────────────────────────────────────
// Flutter Day 1 · Null safety
// Paste this WHOLE file into dartpad.dev, then press Run.
// Handbook: README Part 6 · Null safety
// DartPad shows 3 yellow warnings here (unused 'name', dead code,
// unnecessary '!'). They are DELIBERATE - each one is the point being
// demonstrated. Yellow is fine. Red would not be.
// ────────────────────────────────────────────────────────────

void main() {
  String name = 'Sive';
  // name = null;               // compile error

  String? nickname;             // may be null
  print(nickname?.length);      // null
  print(nickname ?? 'none');    // 'none'
  nickname ??= 'S';             // assign only if null
  print(nickname!.length);      // ! = "trust me, not null", throws if wrong

  String? maybe = DateTime.now().hour > 0 ? 'value' : null;
  if (maybe != null) {
    print(maybe.length);        // promoted to String inside the if
  }
}
