import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';

class QuoteApp extends StatelessWidget{
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Quote App',
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF0B2545),
      useMaterial3: true
    ),
    home: const CaptureScreen(),
  );
}