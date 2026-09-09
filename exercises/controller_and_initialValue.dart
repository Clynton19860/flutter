import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: MakeField())));

class MakeField extends StatefulWidget {
  const MakeField({super.key});
  @override
  State<MakeField> createState() => _MakeFieldState();
}

class _MakeFieldState extends State<MakeField> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _controller,
    decoration: const InputDecoration(labelText: 'Make'),
  );
}