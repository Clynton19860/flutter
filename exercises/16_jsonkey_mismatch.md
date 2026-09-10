# 16 · The breakdown that is always empty

**Day 4 · JSON.** Run in your `quote_app`.

```dart
@JsonSerializable()
class Quote {
  const Quote({required this.id, required this.premium, this.breakdown});

  final String id;
  final double premium;
  final List<String>? breakdown;        // <-- here

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
```

The API returns:

```json
{ "id": "q-1", "premium": 1800.0, "breakdown_lines": ["Base premium"] }
```

## What you should see

No error anywhere. The premium is right. The quote saves, the result screen
opens — and the breakdown list is **always empty**. Run the generator again and
it changes nothing.

## Clue

The generated code looks for a key by the name of the Dart field. Compare that
name, character by character, against the key the server actually sends.

## Why it matters

A nullable field plus a name mismatch equals silent data loss. Nothing throws,
because `null` is a legal value for `List<String>?`. Make the field non-nullable
and you would have got a loud error on the very first response.

The fix is one annotation — and remember to re-run
`dart run build_runner build --delete-conflicting-outputs` afterwards.

---

Solution: `solutions/exercise_16.dart`
