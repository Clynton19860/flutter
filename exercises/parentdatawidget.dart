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
        child: Text('Alpha Insure'),
      ),
    ),
  );
}