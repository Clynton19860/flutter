// Exercise 18: The context that outlived its widget
//
// Every `await` is a point where the user can navigate away. After it, the
// widget that owns this BuildContext may be gone, and touching a dead context
// throws "Looking up a deactivated widget's ancestor is unsafe".
//
// One line, after EVERY await that is followed by context use:
//     if (!context.mounted) return;
//
// The analyzer already tells you: use_build_context_synchronously. Do not
// silence it. It is the difference between a crash you find and one a customer
// finds.

onPressed: () async {
  await ref.read(savedQuotesProvider.notifier).add(quote);

  if (!context.mounted) return;        // <-- the line people forget

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Quote saved')),
  );
  context.go('/saved');
};
