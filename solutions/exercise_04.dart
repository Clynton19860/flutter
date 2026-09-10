// Exercise 04: The cast that compiles and then crashes
//
// Cast through `num`, which is the shared supertype of int and double, then convert. This is why every `fromJson` in the course uses `(j['x'] as num).toDouble()`.

class Quote {
  const Quote({required this.premium});
  final double premium;
}

void main() {
  final json = {'premium': 1450};
  final q = Quote(premium: (json['premium'] as num).toDouble());
  print(q.premium);
}
