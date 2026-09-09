import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

/// Takes an id, not a Quote. Ids survive deep links and process death;
/// objects passed through `extra` do not.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoteProvider);
    final quote = switch (state) {
      QuoteLoaded(:final quote) when quote.id == id => quote,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your quote'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: quote == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 48),
                    const SizedBox(height: 12),
                    Text('Quote not found: $id'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/quote'),
                      child: const Text('Start a new quote'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [PremiumCard(quote: quote)],
              ),
      ),
    );
  }
}
