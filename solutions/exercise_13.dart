// Exercise 13: No ProviderScope found
//
// A provider is a global DESCRIPTION. Its state is created lazily inside a
// ProviderScope, which must wrap the app once, at the root.
//
// Two traps:
//  1. The scope goes ABOVE the widget that reads providers, not inside it.
//  2. main() changed, so you need a HOT RESTART. A hot reload will keep
//     failing and make you think the fix did not work.

void main() {
  runApp(const ProviderScope(child: QuoteApp()));   // was runApp(const QuoteApp())
}

class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(title: brand.name, home: const CaptureScreen());
  }
}
