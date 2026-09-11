import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

import '../data/quote_repository.dart';

class ResultScreen extends ConsumerWidget {
  final String id;

  const ResultScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = switch (ref.watch(quoteProvider)) {
      Loaded(:final quote) when quote.id == id => quote,
      _ => null,
    };
    final saved =
        ref.watch(savedQuotesProvider).value?.where((q) => q.id == id).firstOrNull;
    final quote = live ?? saved;
    final alreadySaved = saved != null;

    if (quote == null) {
      return const Scaffold(
        body: Center(child: Text('Quote not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your quote')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: PremiumCard(quote: quote),
        ),
      ),
      floatingActionButton: FilledButton.icon(
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
    );
  }
}