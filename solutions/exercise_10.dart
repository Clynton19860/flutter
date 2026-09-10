// Exercise 10: Two sources of truth
//
// Set the starting value on the controller and drop `initialValue`. Then dispose the controller. Every controller you create must be disposed or you leak.

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: MakeField())));

class MakeField extends StatefulWidget {
  const MakeField({super.key});
  @override
  State<MakeField> createState() => _MakeFieldState();
}

class _MakeFieldState extends State<MakeField> {
  final _controller = TextEditingController(text: 'VW');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Make'),
      );
}
