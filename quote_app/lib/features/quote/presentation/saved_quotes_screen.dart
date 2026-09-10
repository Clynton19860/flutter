import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/presentation/saved_quotes_provider.dart';

class SavedQuotesScreen extends ConsumerWidget {
  const SavedQuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(savedQuotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved quotes')),
      body: quotesAsync.when(
        data: (quotes) => quotes.isEmpty
            ? const Center(child: Text('No saved quotes yet'))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(savedQuotesProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: quotes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final q = quotes[i];
                    return Dismissible(
                      key: ValueKey(q.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) =>
                          ref.read(savedQuotesProvider.notifier).remove(q.id),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(q.display),
                          subtitle: Text('Quote ${q.id}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/quote/result/${q.id}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load: $e')),
      ),
    );
  }
}
