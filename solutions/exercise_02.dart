// Exercise 02: The list that is not a list
//
// `.toList()` forces the lazy Iterable to produce a real List.

void main() {
  final byMake = {'VW': 1200.0, 'BMW': 2100.0, 'Toyota': 900.0};

  final List<String> cheap = byMake.entries
      .where((e) => e.value < 2000)
      .map((e) => e.key)
      .toList();

  print(cheap);
}
