// Exercise 08: Expanded in the wrong place
//
// Give the Expanded a Flex parent. Or, since there is only one child here, drop the Expanded entirely and use `Center` or `Align`.

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: BrandCard()));

class BrandCard extends StatelessWidget {
  const BrandCard({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Container(
            height: 120,
            color: Colors.indigo.shade50,
            child: const Column(
              children: [
                Expanded(child: Text('Alpha Insure')),
              ],
            ),
          ),
        ),
      );
}
