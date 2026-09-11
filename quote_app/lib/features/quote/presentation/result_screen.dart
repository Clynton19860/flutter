import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = switch (ref.watch(quoteProvider)) {
      QuoteLoaded(:final quote) when quote.id == id => quote,
      _ => null,
    };
    final saved = ref
        .watch(savedQuotesProvider)
        .value
        ?.where((q) => q.id == id)
        .firstOrNull;
    final quote = live ?? saved;

    final alreadySaved = saved != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Your quote')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: quote == null
            ? Center(child: Text('Quote not found: $id'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PremiumCard(quote: quote),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: alreadySaved
                        ? null
                        : () async {
                            await ref.read(savedQuotesProvider.notifier).add(quote);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Quote saved')),
                            );
                            context.go('/saved');
                          },
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(alreadySaved ? 'Saved' : 'Save this quote'),
                  ),
                ],
              ),
      ),
    );
  }
}
