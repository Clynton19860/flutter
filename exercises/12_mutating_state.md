# 12 · The list that never grows

**Day 3 · Riverpod.** Run in your `quote_app`.

```dart
class SavedNotifier extends Notifier<List<Quote>> {
  @override
  List<Quote> build() => [];

  void add(Quote q) {
    state.add(q);                 // <-- here
  }
}
```

## What you should see

Call `add()` and the quote really is in the list — put a `debugPrint` in and you
will see it grow. But every widget watching the provider keeps showing the old
list. Again: no error.

## Clue

Riverpod decides whether to notify by comparing the new state with the old one.
What is being compared here, and did it actually change?

## Why it matters

Riverpod state is immutable by convention. You **assign a new value**, you never
mutate the old one:

- list → `state = [...state, item];`
- object → `state = state.copyWith(...);`

Mutate in place and the provider is handed the same value it already had, so it
correctly concludes nothing happened.

---

Solution: `solutions/exercise_12.dart`

## Answer

```dart
class SavedNotifier extends Notifier<List<Quote>> {
  @override
  List<Quote> build() => [];

  void add(Quote q) {
  //  state.add(q);
    state = [...state, q];                
  }

  void remove(String id) {
    state = state.where((q) => q.id != id).toList();
  }
}
```