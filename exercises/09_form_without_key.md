# 09 · The form that cannot validate

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: SafeArea(child: CaptureForm()))));

class CaptureForm extends StatefulWidget {
  const CaptureForm({super.key});

  @override
  State<CaptureForm> createState() => _CaptureFormState();
}

class _CaptureFormState extends State<CaptureForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Input Value',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Processing: ${_controller.text}')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
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
