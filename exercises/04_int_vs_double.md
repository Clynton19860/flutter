# 04 · The cast that compiles and then crashes

Paste the whole file into **dartpad.dev** (Dart pad) and press Run.

```dart
class Quote {
  const Quote({required this.premium});
  final double premium;
}

void main() {
  final json = {'premium': 1450};
  final q = Quote(premium: json['premium'] as double);
  print(q.premium);
}
```

## What you should see

Nothing at all from the analyser. At runtime: `type 'int' is not a subtype of type 'double' in type cast`

## Clue

The analyser is happy because you told it to be. Look at what is actually in the map, and remember that JSON numbers arrive as whichever type they were written as.

## Why it matters

Real API responses do this constantly. `1450` parses as int, `1450.0` parses as double, and the same endpoint can return both.

---

Solution: `solutions/exercise_04.dart`
