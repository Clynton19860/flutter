// Exercise 14: Watching from a button
//
// `ref.watch` creates a subscription, and a subscription needs a lifecycle to
// tear it down. `build` has one; a callback does not. So watching inside
// onPressed either throws after disposal or leaks a listener.
//
// In callbacks you want a one-off read of the notifier, then call the method.
// riverpod_lint catches this at analysis time.

IconButton(
  icon: const Icon(Icons.swap_horiz),
  tooltip: 'Switch brand',
  onPressed: () => ref.read(brandKeyProvider.notifier).toggle(),  // was ref.watch
);
