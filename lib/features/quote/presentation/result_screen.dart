import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = switch (ref.watch(quoteProvider)) {
      Loaded(:final quote) when quote.id == id => quote,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Quote'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: quote == null
            ? Center(
                child: Text('Quote not found: $id'),
              )
            : PremiumCard(
                quote: quote,
              ),
      ),
    );
  }
}
