// Exercise 09: The form that cannot validate
//
// Hold the form with a `GlobalKey<FormState>` and call `validate()` through it. A `Builder` around the button would also give you a context below the Form, but the key is the pattern this course uses.

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: CaptureForm())));

class CaptureForm extends StatefulWidget {
  const CaptureForm({super.key});
  @override
  State<CaptureForm> createState() => _CaptureFormState();
}

class _CaptureFormState extends State<CaptureForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {}
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
}
