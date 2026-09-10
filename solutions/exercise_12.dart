// Exercise 12: The list that never grows
//
// `state.add(q)` mutates the existing list. Riverpod compares the new state with
// the old one to decide whether to notify - and it is handed the very same list
// object, so it correctly concludes nothing changed.
//
// Assign a NEW value instead. Never mutate the old one.
//   list   -> state = [...state, item];
//   remove -> state = state.where((x) => x.id != id).toList();
//   object -> state = state.copyWith(...);

class SavedNotifier extends Notifier<List<Quote>> {
  @override
  List<Quote> build() => [];

  void add(Quote q) {
    state = [...state, q];        // was state.add(q)
  }

  void remove(String id) {
    state = state.where((q) => q.id != id).toList();
  }
}
