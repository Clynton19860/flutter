// Exercise 03: The switch that misses one
//
// Handle the missing subtype. The object pattern `QuoteFailed(:final message)` destructures the field at the same time.

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
      QuoteFailed(:final message) => 'Error: $message',
    };

void main() => print(describe(const QuoteIdle()));
