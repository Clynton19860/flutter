sealed class QuoteState {
  const QuoteState();
}
class QuoteIdle extends QuoteState { const QuoteIdle(); }
class QuoteLoading extends QuoteState { const QuoteLoading(); }
class QuoteFailed extends QuoteState {
  const QuoteFailed(this.message);
  final String message;
}

String describe(QuoteState s) => switch (s) {
  QuoteIdle() => 'Fill in the form',
  QuoteLoading() => 'Calculating',
  QuoteFailed() => 'Error: ${s.message}',
};

void main() => print(describe(const QuoteIdle()));