import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/core/theme/brand_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(brandKeyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      // Flutter 3.32+ : groupValue/onChanged moved off the individual tiles
      // and onto a RadioGroup ancestor. The old API still compiles but is
      // deprecated and will be removed.
      body: RadioGroup<String>(
        groupValue: key,
        onChanged: (v) => ref.read(brandKeyProvider.notifier).set(v ?? 'alpha'),
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Brand'),
            ),
            for (final entry in brands.entries)
              RadioListTile<String>(
                value: entry.key,
                title: Text(entry.value.name),
                subtitle: Text('Seed ${entry.value.seed}'),
              ),
          ],
        ),
      ),
    );
  }
}
