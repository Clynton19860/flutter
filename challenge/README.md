# THE FIFTH STATE

**First working submission wins a Takealot voucher.**

On Day 3 the recap slide asked: *what would you have to change to add a fifth
state, `QuoteExpired`?* This is that question, as a race.

---

## The rules

1. Start from `lab-4-3-solution` — the app as it stands at the end of Day 4.
2. Copy `challenge/challenge_test.dart` into your app as `test/challenge_test.dart`.
   **Do not edit that file.** Change the app until it passes.
3. You win when **both** of these are clean, in front of the instructor:

   ```
   flutter analyze     # No issues found!
   flutter test        # All tests passed!
   ```

4. `flutter analyze` counts. Green tests with a warning is not a win.
5. Every existing test must still pass. Breaking one to fix another is not a win.
6. Ask anything you like. Use the handbooks, the solutions folder, the internet.
   Pair up if you want — one voucher, so agree how you'd split it first.

---

## What to build

A quote goes stale. Fifteen minutes after it was issued, it is no longer valid
and the customer has to ask again.

### 1. The fifth state

In `quote_model.dart`, alongside the other four:

```dart
class QuoteExpired extends QuoteState {
  const QuoteExpired(this.quote);
  final Quote quote;
}
```

The moment you add it, **the app stops compiling.** That is the point. The
sealed class means every `switch` over `QuoteState` now has a hole in it, and
the compiler will show you exactly where. Fill them in.

### 2. A clock you can control

In `quote_providers.dart`:

```dart
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
```

Nothing in the app should call `DateTime.now()` directly any more — read the
clock from the provider. That is what lets the tests move time forward without
waiting fifteen real minutes, and it is the same dependency-injection seam as
`quoteServiceProvider`.

### 3. Expiry on the notifier

`QuoteNotifier` needs to remember **when** the current quote loaded, and gain:

```dart
void checkExpiry({Duration maxAge = const Duration(minutes: 15)});
```

Behaviour the tests check:

| Situation | Result |
|---|---|
| Loaded, older than `maxAge` | becomes `QuoteExpired`, carrying the same quote |
| Loaded, younger than `maxAge` | stays `QuoteLoaded` |
| Idle, loading or failed | nothing happens |
| `reset()` from expired | back to `QuoteIdle` |
| A new `submit()` after expiry | loads, and the clock starts again |

`maxAge` must be overridable — the tests pass one minute in.

---

## Getting started

```
cd quote_app
git checkout lab-4-3-solution
git checkout -b challenge-<your-name>
cp ../challenge/challenge_test.dart test/
flutter test
```

### What you will see on that first run

**Compile errors, not test failures.** `QuoteExpired` and `clockProvider` do
not exist yet, so the file cannot build:

```
test/challenge_test.dart:35:7: Error: Undefined name 'clockProvider'.
test/challenge_test.dart:47:19: Error: Method not found: 'QuoteExpired'.
test/challenge_test.dart:58:11: Error: 'QuoteExpired' isn't a type.
```

That list is your to-do list. Work down it.

**You will also see `mini_project_flow_test.dart` fail to load.** That is not
your fault and you have not broken anything. `flutter test` compiles the test
files together, so one file that will not build takes another with it. It
comes back on its own the moment `challenge_test.dart` compiles.

Sanity check at any point:

```
flutter test test/quote_notifier_test.dart    # should stay green throughout
```

---

## Hints, if you get stuck

- The first errors are the compiler doing its job. Read them in order.
- `_loadedAt` is ordinary private state on the notifier. It does not need to
  be part of `QuoteState`.
- A failed quote has no load time. Clear it, or `checkExpiry` will do something
  surprising.
- Test 9 is the one people miss: after expiring, a **new** quote must not
  immediately expire as well.
- If a test fails on something you have not touched, read what it actually
  asserts before changing your code.

---

## Roughly what it takes

Around **30 lines across three files.** If you are rewriting half the app, stop
and re-read the spec — you have gone off the path.
