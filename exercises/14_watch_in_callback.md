# 14 · Watching from a button

**Day 3 · Riverpod.** Run in your `quote_app`.

```dart
IconButton(
  icon: const Icon(Icons.swap_horiz),
  onPressed: () {
    final notifier = ref.watch(brandKeyProvider.notifier);   // <-- here
    notifier.toggle();
  },
)
```

## What you should see

It may appear to work. Then, depending on where the widget sits, you get
`Cannot use "ref" after the widget was disposed` — or a listener that is never
cleaned up and fires against a dead widget later.

## Clue

`watch` means "subscribe me, and rebuild me when this changes". Is a button's
`onPressed` callback something that can be rebuilt?

## Why it matters

A subscription created outside `build` has no lifecycle. Nothing tears it down.
`riverpod_lint` flags this one at analysis time, which is the strongest argument
for adding it to the project on Day 5.

---

Solution: `solutions/exercise_14.dart`

## Answer

```dart
IconButton(
  icon: const Icon(Icons.swap_horiz),
  onPressed: () => ref.read(brandKeyProvider.notifier).toggle();  // refactor onPressed
)
```