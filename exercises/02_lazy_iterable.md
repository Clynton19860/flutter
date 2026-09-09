# 02 · The list that is not a list

Paste the whole file into **dartpad.dev** (Dart pad) and press Run.

```dart
void main() {
  final byMake = {
    'VW': 1200.0, 
    'BMW': 2100.0, 
    'Toyota': 900.0};

  // .where() and .map() are lazy. They return an Iterable that is evaluated 
  // only when iterated (e.g., in a loop, toList(), or print()).
  // Currently, 'cheap' is an Iterable<String>, not a List<String>.
  final List<String> cheap = byMake.entries
      .where((e) => e.value < 2000)
      .map((e) => e.key);

  // To force evaluation and get a concrete List, .toList()
  final List<String> cheapList = cheap.toList();

  print('As an Iterable (lazy): $cheap');
  print('As a List (eager): $cheapList');
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
