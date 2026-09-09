class Quote {
  const Quote({required this.premium});
  final double premium;
}

void main() {
  final json = {'premium': 1450};
  final q = Quote(premium: (json['premium'] as num).toDouble());
  print(q.premium);
}