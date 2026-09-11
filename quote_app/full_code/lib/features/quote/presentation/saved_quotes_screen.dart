import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/presentation/saved_quotes_provider.dart';

class SavedQuotesScreen extends ConsumerWidget {
  const SavedQuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedQuotesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved quotes')),
      body: saved.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load: $e')),
        data: (quotes) => quotes.isEmpty
            ? const Center(child: Text('No saved quotes yet'))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(savedQuotesProvider.future),
                child: ListView.builder(
                  itemCount: quotes.length,
                  itemBuilder: (context, i) {
                    final q = quotes[i];
                    return Dismissible(
                      key: ValueKey(q.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete_outline),
                      ),
                      onDismissed: (_) =>
                          ref.read(savedQuotesProvider.notifier).remove(q.id),
                      child: ListTile(
                        title: Text(q.display),
                        subtitle: Text('Ref ${q.id}'),
                        onTap: () => context.go('/quote/result/${q.id}'),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
