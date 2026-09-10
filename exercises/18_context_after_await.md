# 18 · The context that outlived its widget

**Day 4 · Storage.** Run in your `quote_app`.

```dart
onPressed: () async {
  await ref.read(savedQuotesProvider.notifier).add(quote);
  ScaffoldMessenger.of(context).showSnackBar(     // <-- here
    const SnackBar(content: Text('Quote saved')),
  );
  context.go('/saved');
}
```

## What you should see

It works, most of the time. Then a delegate saves a quote and taps Back while the
write is still in flight, and the app throws:
`Looking up a deactivated widget's ancestor is unsafe.`

`flutter analyze` warns: `use_build_context_synchronously`.

## Clue

There is an `await` in the middle of this callback. What might the user have done
during it, and is the widget that owns this `context` still on screen afterwards?

## Why it matters

Every `await` is a point where the user can navigate away. After it, the context
may belong to a widget that no longer exists.

The rule is one line, after **every** await that is followed by context use:

```dart
if (!context.mounted) return;
```

This is the lint you should never switch off. It is the difference between a
crash your delegates find and a crash a customer finds.

---

Solution: `solutions/exercise_18.dart`

## Answer

```dart
onPressed: () async {
  await ref.read(savedQuotesProvider.notifier).add(quote);
  if (!context.mounted) return;                 // <-- guard after the await
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Quote saved')),
  );
  context.go('/saved');
}
```