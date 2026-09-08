# 01 · The greeting that will not compile

Paste the whole file into **dartpad.dev** (Dart pad) and press Run.

```dart
class Driver {
  String? nickname;

  String greet() {
    if (nickname != null) {
      return 'Hello ${nickname?.toUpperCase()}';
    }
    return 'Hello';
  }
}

void main() => print(Driver()..nickname = 'Sive');
```

## What you should see

`The method 'toUpperCase' can't be unconditionally invoked because the receiver can be 'null'`

## Clue

You checked for null on the line above. The compiler still refuses. Ask yourself what is different about `nickname` compared with a local variable, and what another method could do to it between the check and the use.

## Why it matters

This is the single most common Dart surprise for people coming from TypeScript. Flow analysis narrows locals. It cannot narrow fields.

---

Solution: `solutions/exercise_01.dart`
