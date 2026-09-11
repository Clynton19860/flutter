import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class ResultScreen extends ConsumerWidget {
  final String id;

  const ResultScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteState = ref.watch(quoteProvider);
    final content = switch (quoteState) {
      Loaded(quote: final quote) when quote.id == id => PremiumCard(quote: quote),
      _ => const Center(child: Text('Quote not found')),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Your quote')),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: content)),
    );
  }
}