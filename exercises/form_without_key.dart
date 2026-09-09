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