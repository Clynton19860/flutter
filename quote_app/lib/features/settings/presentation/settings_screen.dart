import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/core/theme/brand_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(brandKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: DropdownButtonFormField<String>(
          initialValue: selectedKey,
          decoration: const InputDecoration(labelText: 'Brand'),
          items: brands.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value.name),
                ),
              )
              .toList(),
          onChanged: (key) {
            if (key != null) ref.read(brandKeyProvider.notifier).set(key);
          },
        ),
      ),
    );
  }
}