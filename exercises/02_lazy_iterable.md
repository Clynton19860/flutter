# 02 · The list that is not a list

Paste the whole file into **dartpad.dev** (Dart pad) and press Run.

```dart
void main() {
  final byMake = {'VW': 1200.0, 'BMW': 2100.0, 'Toyota': 900.0};

  final Iterable<String> cheap = byMake.entries
      .where((e) => e.value < 2000)
      .map((e) => e.key);

  print(cheap);
}
```

## What you should see

`A value of type 'Iterable<String>' can't be assigned to a variable of type 'List<String>'`

## Clue

Look at the return type in the error, not the one you asked for. Two of those three method calls are lazy. Nothing has actually run yet.

## Why it matters

This is the number one beginner error in Dart, and it bites hardest inside `children:` where the message is far less clear than this one.

---

Solution: `solutions/exercise_02.dart`
