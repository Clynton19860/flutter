// Exercise 11: The header that stops updating
//
// `ref.read` does a one-off read. It does not subscribe, so the widget is never
// rebuilt when the provider changes. In `build`, always use `ref.watch`.
//
// watch  -> in build. Subscribes and rebuilds.
// read   -> in callbacks (onPressed, onSubmit). No subscription.
// listen -> in build, for side effects (SnackBar, navigation). No rebuild.
// select -> in build, to rebuild on one field only.

class BrandTitle extends ConsumerWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);   // was ref.read
    return Text(brand.name);
  }
}
