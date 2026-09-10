import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/core/theme/brand_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentKey = ref.watch(brandKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioGroup<String>(
            groupValue: currentKey,
            onChanged: (key) =>
                ref.read(brandKeyProvider.notifier).set(key ?? currentKey),
            child: Column(
              children: [
                for (final brand in brands.values)
                  RadioListTile<String>(
                    value: brand.key,
                    title: Text(brand.name),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
