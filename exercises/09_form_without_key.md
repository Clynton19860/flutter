# 09 · The form that cannot validate

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: CaptureForm())));

class CaptureForm extends StatefulWidget {
  const CaptureForm({super.key});
  @override
  State<CaptureForm> createState() => _CaptureFormState();
}

class _CaptureFormState extends State<CaptureForm> {
  @override
  Widget build(BuildContext context) => Form(
        child: Column(
          children: [
            TextFormField(
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            FilledButton(
              onPressed: () {
                if (Form.of(context).validate()) {}
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
}
```

## What you should see

Compiles. Tap Submit and you get: `Form.of() was called with a context that does not contain a Form widget`

## Clue

`Form.of(context)` searches upwards from the context you hand it. Look at which build method that `context` belongs to, and where the Form sits relative to it.

## Why it matters

The same trap catches `Scaffold.of` and `Theme.of`. The context of a build method is above the widget you just created, not inside it.

---

Solution: `solutions/exercise_09.dart`
