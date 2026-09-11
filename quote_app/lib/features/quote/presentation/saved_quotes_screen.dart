import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/data/quote_repository.dart';

class SavedQuotesScreen extends ConsumerWidget {
  const SavedQuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedQuotes = ref.watch(savedQuotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved quotes')),
      body: savedQuotes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Could not load quotes: $error')),
        data: (quotes) => RefreshIndicator(
          onRefresh: () => ref.refresh(savedQuotesProvider.future),
          child: quotes.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 240),
                    Center(child: Text('No saved quotes yet')),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quotes[index];
                    return Dismissible(
                      key: ValueKey(quote.id),
                      direction: DismissDirection.endToStart,
                      background: const ColoredBox(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      onDismissed: (_) =>
                          ref.read(savedQuotesProvider.notifier).remove(quote.id),
                      child: ListTile(
                        title: Text('${quote.currency} ${quote.premium.toStringAsFixed(2)}'),
                        subtitle: Text(quote.id),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/quote/result/${quote.id}'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}