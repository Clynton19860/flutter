import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';
import 'package:quote_app/features/quote/presentation/saved_quotes_provider.dart';

/// Takes an id, never a Quote object. Ids survive deep links and process death.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First look in the live quote flow, then fall back to what is saved -
    // that is what makes a deep link to a saved quote work after a restart.
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
            ? _NotFound(id: id)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PremiumCard(quote: quote),
                  if (quote.breakdown != null) ...[
                    const SizedBox(height: 16),
                    for (final line in quote.breakdown!)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.chevron_right),
                        title: Text(line),
                      ),
                  ],
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: alreadySaved
                        ? null
                        : () async {
                            await ref
                                .read(savedQuotesProvider.notifier)
                                .add(quote);
                            if (!context.mounted) return; // after every await
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

class _NotFound extends StatelessWidget {
  const _NotFound({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) => Center(
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
      );
}
