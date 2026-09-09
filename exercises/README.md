# Find the bug

Ten short programs. Each one has a single deliberate mistake and a clue.

Paste the whole file into **dartpad.dev** and press Run. Exercises 1 to 4 use a
**Dart** pad, 5 to 10 use a **Flutter** pad. Read the error before you read the
clue, and read the clue before you look at the answer.

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

Answers are published in `solutions/` after each block.
