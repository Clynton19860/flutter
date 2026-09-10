# Find the bug

Eighteen short programs. Each one has a single deliberate mistake and a clue.

Read the error before you read the clue, and read the clue before you look at
the answer. Answers are in `solutions/`.

## Days 1 and 2 · paste into DartPad

Paste the whole file into **dartpad.dev** and press Run. Exercises 1 to 4 use a
**Dart** pad, 5 to 10 use a **Flutter** pad.

| # | Exercise | Pad | The error you are looking for |
|---|---|---|---|
| 01 | Field promotion | Dart | A nullable field will not narrow after a null check |
| 02 | Lazy iterable | Dart | `map` and `where` do not give you a List |
| 03 | Exhaustive switch | Dart | A sealed class with a case missing |
| 04 | int vs double | Dart | Compiles, then throws on a JSON cast |
| 05 | Context in initState | Flutter | Inherited lookup before the widget is attached |
| 06 | Row overflow | Flutter | RenderFlex overflowed on the right |
| 07 | Unbounded height | Flutter | Vertical viewport was given unbounded height |
| 08 | ParentDataWidget | Flutter | Expanded with no Flex parent |
| 09 | Form without a key | Flutter | `Form.of()` cannot find the Form |
| 10 | Two sources of truth | Flutter | `controller` and `initialValue` together |

Six of the ten compile perfectly and only fail when you run them. That is the
point. `flutter analyze` cannot see a layout error or a bad inherited lookup,
so running the app is not optional.

## Days 3 and 4 · run in your quote_app

These need Riverpod, go_router, dio and sqflite, so DartPad will not do. Drop
each snippet into the app, hot restart, and watch what happens.

| # | Exercise | Day | The error you are looking for |
|---|---|---|---|
| 11 | read in build | 3 | The widget silently stops updating |
| 12 | Mutating state | 3 | The list grows but nothing rebuilds |
| 13 | Missing ProviderScope | 3 | "ProviderScope not found" — and a hot reload will not fix it |
| 14 | watch in a callback | 3 | A subscription with no lifecycle |
| 15 | Emulator localhost | 4 | "Cannot reach the quote service" with the server running |
| 16 | JsonKey mismatch | 4 | A list that is always empty, silently |
| 17 | Redirect loop | 4 | Onboarding never finishes |
| 18 | Context after await | 4 | "Looking up a deactivated widget's ancestor is unsafe" |

**Seven of these eight fail silently or only under timing.** Numbers 11, 12, 16
and 17 throw nothing at all — no exception, no red screen, clean `flutter
analyze`. That is the real lesson of the second half of the week: once state,
navigation and I/O are involved, the compiler stops being able to help you, and
the only things that catch these are `riverpod_lint`, the analyzer warnings you
did not silence, and actually running the app.
