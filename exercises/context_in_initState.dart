import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: BrandHeader())));

class BrandHeader extends StatefulWidget {
  const BrandHeader({super.key});
  @override
  State<BrandHeader> createState() => _BrandHeaderState();
}

class _BrandHeaderState extends State<BrandHeader> {
  late final Color _accent;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _accent = Theme.of(context).colorScheme.primary;
    return ColoredBox(
      color: _accent,
      child: const SizedBox(height: 80, width: double.infinity),
    );
  }
}
