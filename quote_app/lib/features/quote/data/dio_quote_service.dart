import 'package:dio/dio.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class DioQuoteService implements QuoteService {
  DioQuoteService(this._dio);
  final Dio _dio;

  @override
  Future<Quote> getQuote(QuoteRequest request) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/quote',
        data: request.toJson(),
      );
      return Quote.fromJson(res.data!);
    } on DioException catch (e) {
      throw QuoteException(_message(e));
    }
  }

  /// Turns "SocketException: Connection refused" into something a customer
  /// can read. This is the only place that knows about transport errors.
  String _message(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'The server took too long. Check your connection.',
        DioExceptionType.connectionError => 'Cannot reach the quote service.',
        DioExceptionType.badResponse => switch (e.response?.statusCode) {
            422 => (e.response?.data as Map?)?['message'] as String? ??
                'Invalid request',
            _ => 'Server error (${e.response?.statusCode})',
          },
        _ => 'Unexpected error: ${e.message}',
      };
}

/// toString() returns the bare message, so failures show clean text.
class QuoteException implements Exception {
  QuoteException(this.message);
  final String message;

  @override
  String toString() => message;
}
