# 03 · The switch that misses one

Paste the whole file into **dartpad.dev** (Dart pad) and press Run.

```dart
sealed class QuoteState {
  const QuoteState();
}
class QuoteIdle extends QuoteState { const QuoteIdle(); }
class QuoteLoading extends QuoteState { const QuoteLoading(); }
class QuoteFailed extends QuoteState {
  const QuoteFailed(this.message);
  final String message;
}

String describe(QuoteState s) => switch (s) {
  QuoteIdle() => 'Fill in the form',
  QuoteLoading() => 'Calculating',
  QuoteFailed(:final message) => 'Err: $message'
};

void main() => print(describe(const QuoteFailed('500')));
```

## What you should see

`The type 'QuoteState' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'QuoteFailed()'`

## Clue

Count the subclasses. Now count the cases. The compiler knows the full set because of one keyword on the parent class.

## Why it matters

This is the whole point of sealed classes. Add a state next month and every switch in the app refuses to compile until you handle it. Do not reach for `_` to silence it, that throws the guarantee away.

---

Solution: `solutions/exercise_03.dart`
