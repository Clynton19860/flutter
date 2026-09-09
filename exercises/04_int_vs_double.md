# 04 · The cast that compiles and then crashes

Paste the whole file into **dartpad.dev** (Dart pad) and press Run.

```dart
import 'dart:convert';

/// Represents a financial quote.
/// Uses a flexible constructor to handle JSON-style numeric inputs,
/// ensuring that both [int] and [double] values from API responses
/// are correctly converted to [double].
class Quote {
  const Quote({required this.premium});

  /// Factory constructor to safely parse JSON data.
  factory Quote.fromJson(Map<String, dynamic> json) {
    final rawPremium = json['premium'];

    // Handle potential int/double variations in JSON numbers
    final double premium = (rawPremium is num) 
        ? rawPremium.toDouble() 
        : double.tryParse(rawPremium.toString()) ?? 0.0;

    return Quote(premium: premium);
  }

  final double premium;
}

void main() {
  // Simulating an API response where the value might arrive as an int
  final Map<String, dynamic> jsonInt = {'premium': 1450};
  
  // Simulating an API response where the value might arrive as a double
  final Map<String, dynamic> jsonDouble = {'premium': 1450.50};

  try {
    final q1 = Quote.fromJson(jsonInt);
    final q2 = Quote.fromJson(jsonDouble);

    print('Quote 1 Premium: ${q1.premium}');
    print('Quote 2 Premium: ${q2.premium}');
  } catch (e) {
    print('Failed to parse quote: $e');
  }
}
```

## What you should see

Nothing at all from the analyser. At runtime: `type 'int' is not a subtype of type 'double' in type cast`

## Clue

The analyser is happy because you told it to be. Look at what is actually in the map, and remember that JSON numbers arrive as whichever type they were written as.

## Why it matters

Real API responses do this constantly. `1450` parses as int, `1450.0` parses as double, and the same endpoint can return both.

---

Solution: `solutions/exercise_04.dart`
