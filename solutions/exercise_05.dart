// Exercise 05: The header that dies on the first frame
//
// Read it in `build`, where the widget is attached and the lookup is legal. This widget had no mutable state, so it did not need to be Stateful at all. If you genuinely need it once, use `didChangeDependencies` instead of `initState`.

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: BrandHeader())));

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.primary,
        child: const SizedBox(height: 80, width: double.infinity),
      );
}
